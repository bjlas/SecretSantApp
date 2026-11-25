//
//  models.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 02/11/2026.
//

import Foundation
import SwiftData

@Model
final class Draw {
    var name: String
    var date: Date
    var maxPrice: Decimal?
    var group: Group?
    @Relationship(deleteRule: .cascade, inverse: \Gift.draw) var gifts: [Gift] = []

    init(name: String, maxPrice: Decimal?) {
        self.name = name
        self.date = .now
        self.maxPrice = maxPrice
    }
}
