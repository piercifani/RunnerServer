import Vapor
import Authentication
import FluentSQLite

final class User: SQLiteUUIDModel {

    var id: UUID?
    var facebookID: String
    var userName: String
    var roleString: String

    init(id: UUID? = nil, facebookID: String, userName: String, role: Role) {
        self.id = id
        self.facebookID = facebookID
        self.userName = userName
        self.roleString = role.rawValue
    }
}

extension User: TokenAuthenticatable {
    public typealias TokenType = BearerToken
}

extension Request {
    func user() throws -> User {
        return try requireAuthenticated(User.self)
    }
}

extension User {
    enum Role: String {
        case admin
        case manager
        case user
    }

    var role: Role {
        return Role(rawValue: roleString)!
    }
}

extension User: Migration { }
extension User: Content { }
extension User: Parameter { }
