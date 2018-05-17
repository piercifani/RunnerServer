//
//  Created by Pierluigi Cifani on 17/05/2018.
//

import Vapor
import Fluent
import FluentSQLite
import Authentication

final class BearerToken: SQLiteUUIDModel {
    var id: UUID?

    var token: String
    var userID: UUID

    init(id: UUID? = nil, token: String, userID: UUID) {
        self.id = id
        self.token = token
        self.userID = userID
    }
}

extension BearerToken {
    static func generate(for user: User) throws -> BearerToken {
        let random = try CryptoRandom().generateData(count: 16)
        return try BearerToken(token: random.base64EncodedString(), userID: user.requireID())
    }
}

extension BearerToken {
    var user: Parent<BearerToken, User> {
        return parent(\.userID)
    }
}

extension BearerToken: Token, BearerAuthenticatable {
    static var userIDKey: WritableKeyPath<BearerToken, UUID> {
        return \BearerToken.userID
    }

    static var tokenKey: WritableKeyPath<BearerToken, String> {
        return \BearerToken.token
    }

    typealias UserType = User
}

extension BearerToken: Migration { }
extension BearerToken: Content { }
extension BearerToken: Parameter { }
