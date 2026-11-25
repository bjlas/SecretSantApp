//
//  GroupService.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 05/11/2026.
//


import Foundation
import SwiftData

@MainActor
final class GroupService {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Create / Update

    func saveGroup(
        name: String,
        maxPrice: Decimal?,
        avatar: String,
        editing group: Group?
    ) throws {
        if let group {
            group.name = name
            group.maxPrice = maxPrice
            group.avatar = avatar
        } else {
            context.insert(Group(name: name, maxPrice: maxPrice, avatar: avatar))
        }

        try context.save()
    }
}
