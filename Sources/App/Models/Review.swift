//
//  Review.swift
//  App
//
//  Created by Oleksii Huralnyk on 10.01.2020.
//

import Vapor
import FluentSQLite

/// Review of a particular `Space`
final class Review: SQLiteModel {
    
    var id: Int?
    var rating: Double
}

extension Review: Migration {}
extension Review: Content {}
extension Review: Parameter {}
