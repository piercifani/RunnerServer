import Vapor
import Fluent
import Authentication

class RunController {

    func fetchCurrentUserRuns(_ req: Request) throws -> Future<[Run]> {
        let requestingUser = try req.user()
        return try self.fetchUserRuns(user: requestingUser, req: req)
    }

    func fetchUserRuns(user: User, req: Request) throws -> Future<[Run]> {
        return try user.runs.query(on: req).all()
    }

    func create(_ req: Request) throws -> Future<Run> {
        let requestingUser = try req.user()
        let parseRequest = try req.content.decode(RunCreateData.self)
        let createUser = parseRequest.flatMap { (createData) -> Future<Run> in
            let run = try Run(date: createData.date, lenghtInKM: createData.lenghtInKM, durationInSeconds: createData.durationInSeconds, userID: requestingUser.requireID())
            return run.save(on: req)
        }
        return createUser
    }

    struct RunCreateData: Content {
        let date: Date
        let lenghtInKM: Double
        let durationInSeconds: Double
    }
}
