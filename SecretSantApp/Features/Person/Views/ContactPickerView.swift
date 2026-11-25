import SwiftUI
import ContactsUI
import Foundation

struct ContactPickerView: UIViewControllerRepresentable {
    struct ContactDetails {
        let name: String?
        let phone: String?
        let email: String?
    }

    let onSelect: (ContactDetails?) -> Void

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        private let onSelect: (ContactDetails?) -> Void

        init(onSelect: @escaping (ContactDetails?) -> Void) {
            self.onSelect = onSelect
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            onSelect(ContactDetails(
                name: CNContactFormatter.string(from: contact, style: .fullName),
                phone: contact.phoneNumbers.first?.value.stringValue,
                email: contact.emailAddresses.first.map { String($0.value) }
            ))
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            onSelect(nil)
        }
    }
}
