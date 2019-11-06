import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let spacesController = SpaceController()
    try router.register(collection: spacesController)
}
