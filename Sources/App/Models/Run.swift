import Vapor
import Authentication
import FluentPostgreSQL

final class Run: PostgreSQLUUIDModel {
    var id: UUID?

    var userID: UUID
    var date: Date
    var lenghtInKM: Double
    var durationInSeconds: Double

    init(id: UUID? = nil, date: Date, lenghtInKM: Double, durationInSeconds: Double, userID: UUID) {
        self.id = id
        self.date = date
        self.lenghtInKM = lenghtInKM
        self.durationInSeconds = durationInSeconds
        self.userID = userID
    }
}

extension Run {
    var user: Parent<Run, User> {
        return parent(\.userID)
    }
}
extension Run: Migration { }
extension Run: Content { }
extension Run: Parameter { }
