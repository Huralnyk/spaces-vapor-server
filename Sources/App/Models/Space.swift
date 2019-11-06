import Vapor
import FluentSQLite

/// A single entry of a music rehearsal space
final class Space: SQLiteModel {
    
    var id: Int?
    var name: String
    var address: String
    
    init(id: Int? = nil, name: String, address: String) {
        self.id = id
        self.name = name
        self.address = address
    }
}

extension Space: Migration { }

extension Space: Content { }

extension Space: Parameter { }
