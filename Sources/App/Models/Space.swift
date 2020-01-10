import Vapor
import FluentSQLite

/// A single entry of a music rehearsal space
final class Space: SQLiteModel {
    
    var id: Int?
    var name: String
    var address: String
    var phone: String
    var price: Double
    var location: Coordinate
    
    init(id: Int? = nil, name: String, address: String, phone: String, price: Double, location: Coordinate) {
        self.id = id
        self.name = name
        self.address = address
        self.phone = phone
        self.price = price
        self.location = location
    }
}

extension Space: Migration { }
extension Space: Content { }
extension Space: Parameter { }
