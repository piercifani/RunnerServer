import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let userController = UserController()
    router.post("authenticate-facebook", use: userController.authenticateWithFacebook)

    let runController = RunController()

    let protectedRoutes = [
        router.get("runs", use: runController.fetchCurrentUserRuns),
        router.post("runs", use: runController.create),
        router.get("me", use: userController.requestingUserDetails),
        router.get("users", use: userController.index),
        router.get("user", User.parameter, use: userController.details),
        router.delete("user", User.parameter, use: userController.delete),
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
