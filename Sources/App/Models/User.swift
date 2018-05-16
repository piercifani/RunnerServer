import FluentSQLite
import Vapor

/// A single entry of a Todo list.
final class User: SQLiteModel {

    enum Role: String {
        case admin
        case manager
        case user
    }

    var id: Int?
    var facebookID: String
    var userName: String
    var roleString: String
    var role: Role {
        return Role(rawValue: roleString)!
    }

    /// Creates a new `Todo`.
    init(id: Int? = nil, facebookID: String, userName: String, role: Role) {
        self.id = id
        self.facebookID = facebookID
        self.userName = userName
        self.roleString = role.rawValue
    }
}

extension User: Migration { }
extension User: Content { }
extension User: Parameter { }
