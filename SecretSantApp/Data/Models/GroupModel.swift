//
//  models.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 02/11/2026.
//

import Foundation
import SwiftData

@Model
final class Group {
    var name: String
    var maxPrice: Decimal?
    var avatar: String = availableGroupAvatars.randomElement() ?? "AvatarGroup01"
    
    @Relationship(deleteRule: .cascade, inverse: \Person.group) var persons: [Person] = []
    @Relationship(deleteRule: .cascade, inverse: \Draw.group) var draws: [Draw] = []

    init(name: String, maxPrice: Decimal? = nil, avatar: String = availableGroupAvatars.randomElement() ?? "AvatarGroup01") {
        self.name = name
        self.maxPrice = maxPrice
        self.avatar = avatar
    }
}
