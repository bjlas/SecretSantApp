//
//  models.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 02/11/2026.
//

import Foundation
import SwiftData


@Model
final class Gift {
    var giver: Person?
    var phone: String
    var email: String
    var notificationChannel: String = NotificationChannel.email.rawValue
    var notifiedAt: Date?
    var notificationStatus: String = "pending"
    var target: Person?
    var draw: Draw?

    init(giver: Person, target: Person) {
        self.giver = giver
        self.phone = giver.phone
        self.email = giver.email
        self.notificationChannel = giver.notificationChannel
        self.target = target
    }

    var asunto: String {
        draw?.group?.name ?? draw?.name ?? String(localized: "messages.secret_santa")
    }

    var emailMessage: String {
        let nombreGrupo = draw?.group?.name ?? String(localized: "messages.your_group")
        let giverName = giver?.name ?? ""
        let targetName = target?.name ?? ""
        var texto = localizedFormat(
            NSLocalizedString("messages.email_body", comment: ""),
            nombreGrupo,
            targetName
        )
        texto = localizedFormat(
            NSLocalizedString("messages.email_greeting", comment: ""),
            giverName
        ) + "\n\n" + texto
        if let precio = draw?.maxPrice {
            texto += "\n" + localizedFormat(
                NSLocalizedString("messages.max_budget_reminder", comment: ""),
                formatPrice(precio)
            )
        }
        return texto + "\n\n" + String(localized: "messages.fun_signoff")
    }

    var smsMessage: String {
        let nombreGrupo = draw?.group?.name ?? String(localized: "messages.your_group")
        let targetName = target?.name ?? ""
        var texto = localizedFormat(
            NSLocalizedString("messages.sms_body", comment: ""),
            nombreGrupo,
            targetName
        )
        if let precio = draw?.maxPrice {
            let importe = precio.formatted(.number.precision(.fractionLength(0...2)))
            texto += "\n\n" + localizedFormat(
                NSLocalizedString("messages.budget_reminder", comment: ""),
                importe
            )
        }
        return texto
    }
}
