import Vapor
import Fluent
import Authentication

class RunController {

    func fetchCurrentUserRuns(_ req: Request) throws -> Future<[Run]> {
        let requestingUser = try req.user()
        return try self.fetchUserRuns(user: requestingUser, req: req)
    }

    func fetchRunDetails(_ req: Request) throws -> Future<Run> {
        return try req.parameters.next(Run.self)
    }

    func fetchUserRuns(user: User, req: Request) throws -> Future<[Run]> {
        return try user.runs.query(on: req).all()
    }

    func createRun(_ req: Request) throws -> Future<Run> {
        let requestingUser = try req.user()
        let parseRequest = try req.content.decode(RunCreateData.self)
        let createUser = parseRequest.flatMap { (createData) -> Future<Run> in
            let run = try Run(date: createData.date, lenghtInKM: createData.lenghtInKM, durationInSeconds: createData.durationInSeconds, userID: requestingUser.requireID())
            return run.save(on: req)
        }
        return createUser
    }

    func editRun(_ req: Request) throws -> Future<Run> {

        let runToEdit = try req.parameters.next(Run.self)
        let makeSureWeHavePermissions = runToEdit.map { (run) -> Run in
            let requestingUser = try req.user()
            let requestingUserID = try requestingUser.requireID()
            let userIsEditingItsOwnRun = (run.userID == requestingUserID)
            let userIsAdmin = requestingUser.role == .admin
            guard userIsEditingItsOwnRun || userIsAdmin else {
                throw Abort(.unauthorized, reason: "Your can't edit this Run")
            }
            return run
        }

        let parseRequest = try req.content.decode(RunCreateData.self)
        return parseRequest.and(makeSureWeHavePermissions).flatMap { (createData, run) -> Future<Run> in
            run.date = createData.date
            run.durationInSeconds = createData.durationInSeconds
            run.lenghtInKM = createData.lenghtInKM
            return run.save(on: req)
        }
    }

    struct RunCreateData: Content {
        let date: Date
        let lenghtInKM: Double
        let durationInSeconds: Double
    }
}
