@testable import App
import Vapor
import XCTest

final class AppTests: XCTestCase {
    
    var app: Application!
    
    override func setUp() {
        do {
            var config = Config.default()
            var env = Environment.development
            var services = Services.default()
            
            // clear the command-line arguments because XCTest puts some arguments which confuse Vapor
            env.commandInput.arguments = []
            
            try App.configure(&config, &env, &services)
            
            app = try Application(config: config, environment: env, services: services)
            
            try App.boot(app)
            try app.asyncRun().wait()
        } catch {
            fatalError("Failed to launch Vapor server: \(error.localizedDescription)")
        }
    }
    
    override func tearDown() {
        try? app.runningServer?.close().wait()
    }
    
    static let allTests = [
        ("test_GetSpaces_NoSpaces", test_GetSpaces_NoSpaces),
        ("test_GetSpace_NonExisting", test_GetSpace_NonExisting),
        ("test_CreateSpace", test_CreateSpace)
    ]
    
    func test_GetSpaces_NoSpaces() throws {
        let response = try app.client().get("http://localhost:8080/api/spaces").wait()
        let spaces = try response.content.syncDecode([Space].self)
        XCTAssertEqual(spaces.count, 0)
    }
    
    func test_GetSpace() throws {
        let createdResponse = try app.client().post("http://localhost:8080/api/spaces", beforeSend: { request in
            let space = Space(id: nil, name: "Name", address: "Address", phone: "Phone", price: 100, location: Coordinate(latitude: 1, longitude: 1))
            try request.content.encode(space)
        }).wait()
        
        let created = try? createdResponse.content.syncDecode(Space.self)
        
        guard let id = created?.id else { XCTFail("There should be created space"); return }

        let getResponse = try app.client().get("http://localhost:8080/api/spaces/\(id)").wait()
        let space = try? getResponse.content.syncDecode(Space.self)
        
        XCTAssertNotNil(space, "There should be space")
    }
    
    func test_GetSpace_NonExisting() throws {
        let response = try app.client().get("http://localhost:8080/api/spaces/42").wait()
        let space = try? response.content.syncDecode(Space.self)
        XCTAssertNil(space)
    }
    
    func test_CreateSpace() throws {
        _ = try app.client().post("http://localhost:8080/api/spaces", beforeSend: { request in
            let space = Space(id: nil, name: "Name", address: "Address", phone: "Phone", price: 100, location: Coordinate(latitude: 1, longitude: 1))
            try request.content.encode(space)
        }).wait()
        
        let response = try app.client().get("http://localhost:8080/api/spaces").wait()
        let spaces = try? response.content.syncDecode([Space].self)
        XCTAssertEqual(spaces?.count, 1, "There should be one space created")
        XCTAssertNotNil(spaces?.first?.id, "Creted story should have an ID")
        XCTAssertEqual(spaces?.first?.name, "Name", "Create story should have valid name")
        XCTAssertEqual(spaces?.first?.address, "Address", "Create story should have valid address")
    }
    
    func test_CreateSpace_InvalidData() throws {
        let content = ["title": "Foo", "subtitle": "Bar"]
        
        let response = try app.client().post("http://localhost:8080/api/spaces", beforeSend: { request in
            try request.content.encode(content)
        }).wait()
        
        let space = try? response.content.syncDecode(Space.self)
        
        XCTAssertNil(space, "Creating an invalid space should fail")
    }
    
    func test_UpdateSpace() throws {
        _ = try app.client().post("http://localhost:8080/api/spaces", beforeSend: { request in
            let space = Space(id: nil, name: "Name", address: "Address", phone: "Phone", price: 100, location: Coordinate(latitude: 1, longitude: 1))
            try request.content.encode(space)
        }).wait()
        
        let response = try app.client().get("http://localhost:8080/api/spaces").wait()
        let spaces = try? response.content.syncDecode([Space].self)
        
        guard var created = spaces?.first else { XCTFail("There should be one space created"); return }
        
        created.name = "Modified"
        let updateResponse = try app.client().put("http://localhost:8080/api/spaces/\(created.requireID())", beforeSend: { request in
            try request.content.encode(created)
        }).wait()
        
        let updated = try updateResponse.content.syncDecode(Space.self)
        XCTAssertNotNil(updated, "There should be updated space")
        XCTAssertEqual(updated.id, created.id, "Updated space should have the same ID as original")
        XCTAssertEqual(updated.name, "Modified", "Updated space should have updated name")
        XCTAssertEqual(updated.address, created.address, "Updated space should have the same address as original")
    }
    
    func test_UpdateSpace_NonExisting() throws {
        let space = Space(id: 42, name: "Name", address: "Address", phone: "Phone", price: 100, location: Coordinate(latitude: 1, longitude: 1))
        
        let response = try app.client().put("http://localhost:8080/api/spaces\(space.requireID())", beforeSend: { request in
            try request.content.encode(space)
        }).wait()
        let updatedSpace = try? response.content.syncDecode(Space.self)
        
        XCTAssertNil(updatedSpace, "There should be no updated space on empty database")
    }
    
    func test_DeleteSpace() throws {
        let createdResponse = try app.client().post("http://localhost:8080/api/spaces", beforeSend: { request in
            let space = Space(id: nil, name: "Name", address: "Address", phone: "Phone", price: 100, location: Coordinate(latitude: 1, longitude: 1))
            try request.content.encode(space)
        }).wait()
        
        let created = try? createdResponse.content.syncDecode(Space.self)
        
        guard let id = created?.id else { XCTFail("There should be created space"); return }

        _ = try app.client().delete("http://localhost:8080/api/spaces/\(id)").wait()
        
        let getResponse = try app.client().get("http://localhost:8080/api/spaces").wait()
        let spaces = try getResponse.content.syncDecode([Space].self)
        XCTAssertEqual(spaces.count, 0, "Space should be deleted")
    }
}
