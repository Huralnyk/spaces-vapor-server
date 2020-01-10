import Vapor
import FluentSQLite

/// A single entry of a music rehearsal space
struct Space: SQLiteModel {
    var id: Int?
    var name: String
    var address: String
    var phone: String
    var price: Double
    var location: Coordinate
}

extension Space: Migration { }
extension Space: Content { }
extension Space: Parameter { }
