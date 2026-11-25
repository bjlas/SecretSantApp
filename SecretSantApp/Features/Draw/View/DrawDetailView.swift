//
//  DrawDetailView.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 16/11/2026.
//

import SwiftUI
import MessageUI
import SwiftData

struct DrawDetailView: View {
    let draw: Draw
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @StateObject private var googleAuth = GoogleAuthManager()
    @State private var composerRequest: DrawComposerRequest?
    @State private var errorMessage: String?
    @State private var showData: Bool = false;
    
    private var gifts: [Gift] { draw.gifts.sorted { ($0.giver?.name ?? "") < ($1.giver?.name ?? "") } }


    var body: some View {
        ZStack {
            Color.personScreenBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text(draw.date.formatted(date: .long, time: .omitted))
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                        Text(draw.date.formatted(date: .omitted, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    ForEach(gifts) { gift in
                        DrawCard(
                            gift: gift,
                            showData: showData,
                            onResendSMS: { openComposer(for: gift, channel: .sms) },
                            onResendEmail: { Task { await resendEmail(for: gift) } }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showData.toggle() } label: {
                    Image(systemName: showData ? "eye.slash" : "eye")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.accent, in: Circle())
                }
                .accessibilityLabel(showData ? "draws.results.hide" : "draws.results.show")

            }
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.accent)
                }
                .accessibilityLabel("common.back")
            }
            
            
            
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(item: $composerRequest) { request in
            if request.channel == .sms {
                MessageComposer(gift: request.gift) { sent in
                    recordResend(for: request.gift, channel: .sms, sent: sent)
                    composerRequest = nil
                }
                .ignoresSafeArea()
            } else {
                MailComposer(gift: request.gift) { sent in
                    recordResend(for: request.gift, channel: .email, sent: sent)
                    composerRequest = nil
                }
                .ignoresSafeArea()
            }
        }
        .alert("draws.could_not_resend_the_message", isPresented: errorAlertIsPresented) {
            Button("common.ok", role: .cancel) { errorMessage = nil }
        } message: {
            Text(LocalizedStringKey(errorMessage ?? "draws.please_try_again"))
        }
    }

    private var errorAlertIsPresented: Binding<Bool> {
        Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
    }

    private func openComposer(for gift: Gift, channel: NotificationChannel) {
        guard channel != .email || MFMailComposeViewController.canSendMail() else {
            errorMessage = String(localized: "draws.mail_is_not_set_up_on_this_device")
            return
        }
        composerRequest = DrawComposerRequest(gift: gift, channel: channel)
    }

    @MainActor
    private func resendEmail(for gift: Gift) async {
        guard !gift.email.isEmpty else {
            errorMessage = String(localized: "draws.error.missing_email")
            return
        }
        await googleAuth.waitForSessionRestoration()
        if googleAuth.canSendWithGmail {
            do {
                let token = try await googleAuth.getGmailAccessToken()
                try await GmailService.shared.sendEmail(
                    to: gift.email,
                    subject: gift.asunto,
                    body: gift.emailMessage,
                    accessToken: token
                )
                recordResend(for: gift, channel: .email, sent: true)
                return
            } catch {
                // Use Apple's mail composer as a manual fallback.
            }
        }
        openComposer(for: gift, channel: .email)
    }

    private func recordResend(for gift: Gift, channel: NotificationChannel, sent: Bool) {
        if sent {
            gift.notificationChannel = channel.rawValue
            gift.notifiedAt = .now
            gift.notificationStatus = channel.rawValue
        } else if gift.notifiedAt == nil {
            gift.notificationStatus = "cancelled"
        }
        do {
            try context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

}

private struct DrawComposerRequest: Identifiable {
    let id = UUID()
    let gift: Gift
    let channel: NotificationChannel
}



#Preview {
    let container = try! ModelContainer(
        for: Group.self, Person.self, Draw.self, Gift.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let group = Group(
        name: "Navidad 2026",
        maxPrice: 30,
    )
    
    group.avatar = "AvatarGroup01"
    
    let draw = Draw(name: "Navidad 2025", maxPrice: 30)
    draw.date = Calendar.current.date(
        from: DateComponents(year: 2025, month: 12, day: 15, hour: 18, minute: 30)
    ) ?? .now
    let participants = [
        Person(name: "Blas", phone: "+34600111222", email: "blas@example.com", avatar: "AvatarPerson01"),
        Person(name: "María", phone: "+34600222333", email: "maria@example.com", avatar: "AvatarPerson02"),
        Person(name: "Carlos", phone: "+34600333444", email: "carlos@example.com", avatar: "AvatarPerson03"),
        Person(name: "Laura", phone: "+34600444555", email: "laura@example.com", avatar: "AvatarPerson04")
    ]
    let gifts = [
        Gift(giver: participants[0], target: participants[1]),
        Gift(giver: participants[1], target: participants[2]),
        Gift(giver: participants[2], target: participants[3]),
        Gift(giver: participants[3], target: participants[0])
    ]
    gifts[0].notificationStatus = NotificationChannel.email.rawValue
    gifts[0].notifiedAt = draw.date
    gifts[1].notificationChannel = NotificationChannel.sms.rawValue
    gifts[1].notificationStatus = NotificationChannel.sms.rawValue
    gifts[1].notifiedAt = draw.date
    draw.gifts = gifts
    draw.group = group
    group.persons = participants
    
    participants.forEach { container.mainContext.insert($0) }
    container.mainContext.insert(draw)
    gifts.forEach { container.mainContext.insert($0) }

    return NavigationStack {
        DrawDetailView(draw: draw)
    }
    .modelContainer(container)
}
