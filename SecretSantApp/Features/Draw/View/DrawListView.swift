//
//  DrawListView.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 16/11/2026.
//

import SwiftUI
import SwiftData

struct DrawListView: View {
    let group: Group
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage: String?
    @State private var createdDraw: Draw?
    @State private var selectedDraw: Draw?
    @State private var showDrawDetail = false
    @State private var askToNotify = false
    @State private var showNotificationComposer = false
    @State private var isSendingNotifications = false
    @StateObject private var googleAuth = GoogleAuthManager()

    private var draws: [Draw] { group.draws.sorted { $0.date > $1.date } }

    var body: some View {
        List {
                Section {

                        ForEach(draws) { draw in
                            Button {
                                selectedDraw = draw
                                showDrawDetail = true
                            } label: {
                                FormSectionCard {
                                    HStack {
                                        Text(draw.date.formatted(date: .long, time: .shortened))
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        Image(systemName: "chevron.right")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                context.delete(draws[index])
                            }
                            try? context.save()
                        }
                    
                } header: {
                    
                    Text(localizedFormat(
                        NSLocalizedString("draws.history.title", comment: ""),
                        draws.count
                    ))
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .textCase(nil)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 5)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.personScreenBackground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PrimaryButton(
                title: isSendingNotifications ? "draws.sending_notifications" : "draws.action.run",
                action: performDraw
            )
                .disabled(group.persons.count < 3 || isSendingNotifications)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(Color.personScreenBackground)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            
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
        .navigationTitle("draws.title")
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showDrawDetail) {
            if let selectedDraw {
                DrawDetailView(draw: selectedDraw)
            }
        }
        .alert("draws.could_not_run_the_draw", isPresented: errorAlertIsPresented) {
            Button("common.ok", role: .cancel) { errorMessage = nil }
        } message: {
            Text(LocalizedStringKey(errorMessage ?? "draws.please_try_again"))
        }
        .alert("draws.notify_everyone", isPresented: $askToNotify) {
            Button("draws.not_now", role: .cancel) { }
            Button("draws.yes_continue") { Task { await notifyParticipants() } }
        } message: {
            Text("draws.notify.confirmation")
        }
        .sheet(isPresented: $showNotificationComposer) {
            if let createdDraw {
                NotificationSequenceView(draw: createdDraw, channels: [.email, .sms])
            }
        }
    }

    private var errorAlertIsPresented: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func performDraw() {
        do {
            createdDraw = try DrawService().createDraw(for: group, in: context)
            askToNotify = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func notifyParticipants() async {
        guard let draw = createdDraw else { return }
        isSendingNotifications = true
        defer { isSendingNotifications = false }

        await googleAuth.waitForSessionRestoration()
        let emailGifts = draw.gifts.filter { $0.notificationChannel == NotificationChannel.email.rawValue }
        if !emailGifts.isEmpty && googleAuth.canSendWithGmail {
            do {
                let token = try await googleAuth.getGmailAccessToken()
                for gift in emailGifts where gift.notifiedAt == nil {
                    do {
                        try await GmailService.shared.sendEmail(
                            to: gift.email,
                            subject: gift.asunto,
                            body: gift.emailMessage,
                            accessToken: token
                        )
                        gift.notifiedAt = .now
                        gift.notificationStatus = NotificationChannel.email.rawValue
                        try context.save()
                    } catch {
                        gift.notificationStatus = "failed"
                        try? context.save()
                    }
                }
            } catch { /* Fall back to Mail for any email not sent through Gmail. */ }
        }

        let unsentGifts = draw.gifts.filter { $0.notifiedAt == nil }
        if !unsentGifts.isEmpty {
            showNotificationComposer = true
        }
    }
}


#Preview {
    let container = try! ModelContainer(
        for: Group.self, Person.self, Draw.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let group = Group(
        name: "Navidad 2026",
        maxPrice: 30,
    )

    group.avatar = "AvatarGroup01"

    let persons = [
        Person(name: "Blas", avatar: "AvatarPerson01"),
        Person(name: "María", avatar: "AvatarPerson02"),
        Person(name: "Carlos", avatar: "AvatarPerson03"),
        Person(name: "Laura", avatar: "AvatarPerson04")
    ]
    
    let calendar = Calendar.current
    let draws = [
        Draw(name: "Navidad 2026", maxPrice: 30),
        Draw(name: "Amigo invisible 2025", maxPrice: 25),
        Draw(name: "Intercambio de primavera", maxPrice: 20)
    ]
    draws[0].date = calendar.date(from: DateComponents(year: 2026, month: 11, day: 20, hour: 18, minute: 30)) ?? .now
    draws[1].date = calendar.date(from: DateComponents(year: 2025, month: 12, day: 12, hour: 19, minute: 0)) ?? .now
    draws[2].date = calendar.date(from: DateComponents(year: 2025, month: 4, day: 5, hour: 12, minute: 15)) ?? .now

    group.persons = persons
    group.draws = draws
    container.mainContext.insert(group)

    return NavigationStack {
        DrawListView(group: group)
    }
    .modelContainer(container)
}
