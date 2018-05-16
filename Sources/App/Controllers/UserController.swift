import Vapor
import Turnstile
import TurnstileWeb

class UserController {

    private let facebookClient = FacebookClient()

    func authenticateWithFacebook(_ req: Request) throws -> Future<User> {

        let loginRequest = try req.content.decode(LoginRequest.self)
        var role: String!
        let facebookDetails = loginRequest.map { loginRequest -> FacebookClient.LoginResponse in
            role = loginRequest.role
            return try self.facebookClient.fetchUserWithFacebook(userToken: loginRequest.authToken)
        }

        let createUser = facebookDetails.map { facebookDetails -> User in

            guard let role = User.Role(rawValue: role) else {
                throw Abort(HTTPResponseStatus.badRequest, reason: "Invalid Role")
            }
            return User(facebookID: facebookDetails.id, userName: facebookDetails.name, role: role)
        }

        let saveUser = createUser.flatMap {
            $0.save(on: req)
        }

        return saveUser
    }

    struct LoginRequest: Content {
        var authToken: String
        var role: String
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
