import Vapor

struct SpaceController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("api", "spaces")
        group.get(use: getAllHandler)
        group.get(Space.parameter, use: getHandler)
        group.post(Space.self, use: createHandler)
        group.put(Space.parameter, use: updateHandler)
        group.delete(Space.parameter, use: deleteHandler)
    }
    
    private func getAllHandler(_ req: Request) throws -> Future<[Space]> {
        return Space.query(on: req).all()
    }
    
    private func getHandler(_ req: Request) throws -> Future<Space> {
        return try req.parameters.next(Space.self)
    }
    
    private func createHandler(_ req: Request, space: Space) throws -> Future<Space> {
        return space.save(on: req)
    }
    
    private func updateHandler(_ req: Request) throws -> Future<Space> {
        return try flatMap(req.parameters.next(Space.self), req.content.decode(Space.self), { original, updated in
            original.name = updated.name
            original.address = updated.address
            return original.save(on: req)
        })
    }
    
    private func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Space.self).flatMap { space in
            return space.delete(on: req)
        }.transform(to: .noContent)
    }
}
