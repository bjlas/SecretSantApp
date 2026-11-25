import SwiftUI
import SwiftData
import MessageUI

struct NotificationSequenceView: View {
    let draw: Draw
    let channels: Set<NotificationChannel>
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var index: Int
    @State private var error: String?
    @State private var selectedGift: Gift?

    @State private var gifts: [Gift]

    init(draw: Draw, channels: Set<NotificationChannel> = [.sms]) {
        self.draw = draw
        self.channels = channels
        let matchingGifts = draw.gifts
            .filter { channels.contains(NotificationChannel(rawValue: $0.notificationChannel) ?? .email) && $0.notifiedAt == nil }
            .sorted { ($0.giver?.name ?? "") < ($1.giver?.name ?? "") }
        _gifts = State(initialValue: matchingGifts)
        _index = State(initialValue: 0)
    }

    var body: some View {
        NavigationStack {
            SwiftUI.Group {
                if gifts.isEmpty {
                    ContentUnavailableView("draws.notifications_ready", systemImage: "checkmark.circle", description: Text("draws.all_participants_have_been_processed"))
                } else if index >= gifts.count {
                    ContentUnavailableView("draws.process_complete", systemImage: "checkmark.circle.fill", description: Text("draws.notifications.saved"))
                } else {
                    let gift = gifts[index]
                    VStack(spacing: 18) {
                        Text(localizedFormat(
                            NSLocalizedString("common.of", comment: ""),
                            index + 1,
                            gifts.count
                        ))
                        .foregroundStyle(.secondary)
                        Text(localizedFormat(
                            NSLocalizedString("common.send_to", comment: ""),
                            gift.giver?.name ?? String(localized: "people.generic")
                        ))
                        .font(.title2.bold())
                        Text(gift.notificationChannel == NotificationChannel.sms.rawValue ? gift.smsMessage : gift.emailMessage)
                            .multilineTextAlignment(.center)
                        if let error { Text(error).foregroundStyle(.red) }
                        if gift.notificationChannel == NotificationChannel.sms.rawValue {
                            if MFMessageComposeViewController.canSendText() {
                                Button("draws.open_messages") { selectedGift = gift }
                                    .buttonStyle(.borderedProminent)
                            } else {
                                Text("draws.messages.unavailable").foregroundStyle(.secondary)
                            }
                        } else if MFMailComposeViewController.canSendMail() {
                            Button("draws.open_mail") { selectedGift = gift }
                                .buttonStyle(.borderedProminent)
                        } else {
                            Text("draws.mail_is_not_set_up_on_this_device").foregroundStyle(.secondary)
                        }
                        Button("draws.skip") { index += 1 }
                    }
                    .padding()
                }
                
            }
            .navigationTitle("draws.notify_participants")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("common.done") { dismiss() } } }
            .sheet(item: $selectedGift) { gift in
                if gift.notificationChannel == NotificationChannel.sms.rawValue {
                    MessageComposer(gift: gift) { sent in finish(gift, sent: sent) }
                        .ignoresSafeArea()
                } else {
                    MailComposer(gift: gift) { sent in finish(gift, sent: sent) }
                        .ignoresSafeArea()
                }
            }
        }
    }

    private func finish(_ gift: Gift, sent: Bool) {
        if sent {
            gift.notifiedAt = .now
            gift.notificationStatus = gift.notificationChannel
            try? context.save()
        } else {
            gift.notificationStatus = "cancelled"
            try? context.save()
        }
        selectedGift = nil
        index += 1
    }
}

struct MessageComposer: UIViewControllerRepresentable {
    let gift: Gift
    let completion: (Bool) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(completion: completion) }
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.recipients = [gift.phone]
        controller.body = gift.smsMessage
        controller.messageComposeDelegate = context.coordinator
        return controller
    }
    func updateUIViewController(_ controller: MFMessageComposeViewController, context: Context) {}
    final class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let completion: (Bool) -> Void
        init(completion: @escaping (Bool) -> Void) { self.completion = completion }
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true) { self.completion(result == .sent) }
        }
    }
}

struct MailComposer: UIViewControllerRepresentable {
    let gift: Gift
    let completion: (Bool) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(completion: completion) }
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.setToRecipients([gift.email])
        controller.setSubject(gift.asunto)
        controller.setMessageBody(gift.emailMessage, isHTML: false)
        controller.mailComposeDelegate = context.coordinator
        return controller
    }
    func updateUIViewController(_ controller: MFMailComposeViewController, context: Context) {}
    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let completion: (Bool) -> Void
        init(completion: @escaping (Bool) -> Void) { self.completion = completion }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true) { self.completion(result == .sent) }
        }
    }
}
