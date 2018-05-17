import FluentSQLite
import Vapor

/// A single entry of a Todo list.
final class Todo: SQLiteUUIDModel {
    /// The unique identifier for this `Todo`.
    var id: UUID?

    /// A title describing what this `Todo` entails.
    var title: String

    /// Creates a new `Todo`.
    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Todo: Migration { }

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Todo: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Todo: Parameter { }
