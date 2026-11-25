//
//  Card.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 02/11/2026.
//
import SwiftUI
import MessageUI


struct DrawCard: View {
    let gift: Gift
    let showData: Bool
    let onResendSMS: () -> Void
    let onResendEmail: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizedFormat(
                        NSLocalizedString("common.gives_a_gift_to", comment: ""),
                        gift.giver?.name ?? String(localized: "people.generic")
                    ))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                
                    Text(showData ? (gift.target?.name ?? String(localized: "people.generic")) : "****")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                }
                Spacer()
            }
            
            if let notifiedAt = gift.notifiedAt {
                Text(localizedFormat(
                    NSLocalizedString("common.notified_by", comment: ""),
                    gift.notificationChannel == NotificationChannel.sms.rawValue
                        ? String(localized: "people.channel.sms")
                        : String(localized: "people.channel.email"),
                    notifiedAt.formatted(date: .abbreviated, time: .shortened)
                ))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.personFieldBackground, in: RoundedRectangle(cornerRadius: 12))
            }

            HStack(spacing: 10) {
                Button(action: onResendSMS) {
                    Label("people.channel.sms", systemImage: "message")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .foregroundStyle(.white)
                        .background(Color.accent, in: Capsule())
                }
                .buttonStyle(.plain)
                .disabled(gift.phone.isEmpty || !MFMessageComposeViewController.canSendText())

                Button(action: onResendEmail) {
                    Label("draws.email", systemImage: "envelope")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .foregroundStyle(Color.accent)
                        .background(Color.accentSoft, in: Capsule())
                }
                .buttonStyle(.plain)
                .disabled(gift.email.isEmpty)
            }
        }
        .padding(18)
        .background(Color.personSurface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct FormSectionCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(Color.personSurface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct FormSectionHeading: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
