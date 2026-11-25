//
//  models.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 02/11/2026.
//

import Foundation
import SwiftData


@Model
final class Person {

    var id: UUID
    var name: String
    var phone: String
    var email: String
    var notificationChannel: String = NotificationChannel.email.rawValue
    var avatar: String = availablePersonAvatars.randomElement() ?? "AvatarPerson01"
    var noGift: [UUID] = []
    var group: Group?
    @Relationship(deleteRule: .nullify, inverse: \Gift.giver) var giftsGiven: [Gift] = []
    @Relationship(deleteRule: .nullify, inverse: \Gift.target) var giftsReceived: [Gift] = []


    init(
        name: String,
        phone: String = "",
        email: String = "",
        avatar: String = availablePersonAvatars.randomElement() ?? "AvatarPerson01"
    ) {

        self.id = UUID()
        self.name = name
        self.phone = phone
        self.email = email
        self.avatar = avatar
    }
}

enum NotificationChannel: String, CaseIterable, Identifiable {
    case email = "email"
    case sms = "sms"

    var id: String { rawValue }
}
