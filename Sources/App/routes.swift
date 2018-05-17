import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let userController = UserController()
    router.post("authenticate-facebook", use: userController.authenticateWithFacebook)

    let protectedRoutes = [
        router.get("user", use: userController.userDetails)
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
