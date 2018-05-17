import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    let tokenAuthMiddleware = User.tokenAuthMiddleware()

    let userController = UserController()
    router.post("authenticate-facebook", use: userController.authenticateWithFacebook)
    router.get("user", use: userController.userDetails)
}
