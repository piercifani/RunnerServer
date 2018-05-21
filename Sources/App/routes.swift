import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let runController = RunController()
    let userController = UserController(runController: runController)
    router.post("authenticate-facebook", use: userController.authenticateWithFacebook)

    let protectedRoutes = [
        router.get("me", use: userController.fetchCurrentUserDetails),
        router.get("users", use: userController.fetchAllUsers),
        router.get("users", User.parameter, use: userController.fetchUserDetails),
        router.delete("users", User.parameter, use: userController.delete),
        router.get("users", User.parameter, "runs", use: userController.fetchUserRuns),
        router.get("runs", use: runController.fetchCurrentUserRuns),
        router.get("runs", Run.parameter, use: runController.fetchRunDetails),
        router.post("runs", use: runController.createRun),
        router.put("runs", Run.parameter, use: runController.editRun),
    ]

    protectedRoutes.addMiddleware(tokenAuthMiddleware, router: router)
}

extension Array where Element == Route<Responder> {
    func addMiddleware(_ middleware: Middleware, router: Router) {
        let middlewareRoute = router.grouped(middleware)
        forEach { (route) in
            middlewareRoute.register(route: route)
        }
    }
}
