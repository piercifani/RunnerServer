import Vapor
import Turnstile
import TurnstileWeb

class UserController {

    private let facebook = Facebook(
        clientID: "194840897775038",
        clientSecret: "cPh_UdAw4h1Y-xTmGw3x5w6NPGU"
    )

    func authenticateWithFacebook(_ req: Request) throws -> Future<FacebookLoginResponse> {

        let userToken = try req.content.decode(FacebookLoginRequest.self).map(to: String.self) { request in
            return request.authToken
        }

        var userTokenString: String!
        let userID = userToken.map { (_userToken) -> String in
            userTokenString = _userToken
            return try self.loginWithFacebook(userToken: _userToken)
        }

        let userDetails = userID.map {
            return try self.fetchDetails(userID: $0, accesToken: userTokenString)
        }

        let response = userDetails.map { (details) -> FacebookLoginResponse in
            print(details)
            return FacebookLoginResponse()
        }

        return response
    }

    private func loginWithFacebook(userToken: String) throws -> String {
        let token = AccessToken(string: userToken)
        let user = try facebook.authenticate(credentials: token)
        return user.uniqueID
    }

    private func fetchDetails(userID: String, accesToken: String) throws -> [String: String] {
        let details = try facebook.fetchDetailsFromUser(userID: userID, accesToken: accesToken, details: ["name"])
        return details
    }

    struct FacebookLoginRequest: Content {
        var authToken: String
    }

    struct FacebookLoginResponse: Content {

    }
}

extension Facebook {

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
