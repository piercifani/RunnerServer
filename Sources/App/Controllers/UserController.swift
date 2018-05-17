import Vapor
import Turnstile
import TurnstileWeb
import Fluent
import Authentication

class UserController {

    private let facebookClient = FacebookClient()

    func userDetails(_ req: Request) throws -> Future<User> {
        return req.eventLoop.submit { () -> User in
            return try req.user()
        }
    }

    func authenticateWithFacebook(_ req: Request) throws -> Future<LoginResponse> {

        // Transient properties
        var _role: String!
        var _facebookDetails: FacebookClient.LoginResponse!
        var _user: User!

        let loginRequest = try req.content.decode(LoginRequest.self)
        let fetchFacebookDetails = loginRequest.map { loginRequest -> FacebookClient.LoginResponse in
            _role = loginRequest.role
            return try self.facebookClient.fetchUserWithFacebook(userToken: loginRequest.authToken)
        }

        let queryExistingUser = fetchFacebookDetails.flatMap { facebookDetails -> Future<User?> in
            _facebookDetails = facebookDetails
            return try User.query(on: req).filter(\.facebookID == facebookDetails.id).first()
        }

        let updatedUser = queryExistingUser.flatMap({ (user) -> Future<User> in

            guard let role = User.Role(rawValue: _role) else {
                throw Abort(HTTPResponseStatus.badRequest, reason: "Invalid Role")
            }

            if let user = user {
                user.roleString = role.rawValue
                user.userName = _facebookDetails.name
                return user.update(on: req)
            } else {
                let createdUser = User(facebookID: _facebookDetails.id, userName: _facebookDetails.name, role: role)
                return createdUser.save(on: req)
            }
        })

        let generateToken = updatedUser.flatMap { (user) -> Future<BearerToken> in
            _user = user
            let token = try BearerToken.generate(for: user)
            return token.save(on: req)
        }

        return generateToken.map { (token) -> (LoginResponse) in
            return LoginResponse(user: _user, token: token)
        }
    }

    struct LoginRequest: Content {
        var authToken: String
        var role: String
    }

    struct LoginResponse: Content {
        var user: User
        var token: BearerToken
    }
}

fileprivate extension UserController {

    class FacebookClient {

        private let facebook = Facebook(
            clientID: "194840897775038",
            clientSecret: "cPh_UdAw4h1Y-xTmGw3x5w6NPGU"
        )

        func fetchUserWithFacebook(userToken: String) throws -> LoginResponse {
            let userID = try self.loginWithFacebook(userToken: userToken)
            let userDetails = try self.fetchDetails(userID: userID, accesToken: userToken)
            return userDetails
        }

        private func loginWithFacebook(userToken: String) throws -> String {
            let token = AccessToken(string: userToken)
            let user = try facebook.authenticate(credentials: token)
            return user.uniqueID
        }

        private func fetchDetails(userID: String, accesToken: String) throws -> LoginResponse {
            let details = try facebook.fetchDetailsFromUser(userID: userID, accesToken: accesToken, details: ["name"])
            guard let name = details["name"] else {
                throw FacebookError(json: [String: Any]())
            }
            return LoginResponse(name: name, id: userID)
        }

        struct LoginResponse: Content {
            let name: String
            let id: String
        }
    }
}

fileprivate extension Facebook {

    func fetchDetailsFromUser(userID: String, accesToken: String, details: [String]) throws -> [String: String] {
        var urlComponents = URLComponents(string: "https://graph.facebook.com/\(userID)")!
        urlComponents.queryItems = [
            URLQueryItem(name: "fields", value: details.joined(separator: ",")),
            URLQueryItem(name: "access_token", value: accesToken)
        ]
        guard let url = urlComponents.url else {
            throw FacebookError(json: [String: Any]())
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        guard let data = (try? urlSession.executeRequest(request: request))?.0 else {
            throw APIConnectionError()
        }
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: String] else {
            throw InvalidAPIResponse()
        }

        return json
    }
}
