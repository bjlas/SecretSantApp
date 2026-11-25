//
//  PersonService.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 05/11/2026.
//


import Foundation
import SwiftData

@MainActor
final class PersonService {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Create / Update

    func savePerson(
        form: PersonFormModel,
        group: Group,
        editing: Person?
    ) throws {

        if let editing {

            editing.name = form.name
            editing.email = form.email
            editing.phone = form.phone
            editing.notificationChannel = form.notificationChannel.rawValue
            editing.noGift = form.noGift
            editing.avatar = form.avatar

        } else {

            let person = Person(
                name: form.name,
                phone: form.phone,
                email: form.email,
                avatar: form.avatar
            )

            person.group = group
            person.notificationChannel = form.notificationChannel.rawValue
            person.noGift = form.noGift

            context.insert(person)
        }

        try context.save()
    }
}
