import Foundation
import Combine
import StoreKit

@MainActor
final class DonationStore: ObservableObject {
    static let productIDs = [
        "bjlas.SecretSantApp.tip.small",
        "bjlas.SecretSantApp.tip.medium",
        "bjlas.SecretSantApp.tip.large"
    ]

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published var alert: DonationAlert?
    private var transactionUpdates: Task<Void, Never>?

    init() {
        transactionUpdates = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self,
                      case .verified(let transaction) = result,
                      Self.productIDs.contains(transaction.productID) else { continue }
                await transaction.finish()
                self.alert = DonationAlert(
                    title: String(localized: "settings.donations.thank_you_title"),
                    message: String(localized: "settings.donations.thank_you_message")
                )
            }
        }
    }

    func loadProducts() async {
        guard products.isEmpty, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: Self.productIDs)
                .filter { $0.type == .consumable }
                .sorted { Self.productIDs.firstIndex(of: $0.id)! < Self.productIDs.firstIndex(of: $1.id)! }
        } catch {
            alert = DonationAlert(
                title: String(localized: "settings.donations.error_title"),
                message: String(localized: "settings.donations.load_error")
            )
        }
    }

    func purchase(_ product: Product) async {
        do {
            switch try await product.purchase() {
            case .success(let result):
                guard case .verified(let transaction) = result else {
                    alert = DonationAlert(
                        title: String(localized: "settings.donations.error_title"),
                        message: String(localized: "settings.donations.verify_error")
                    )
                    return
                }
                await transaction.finish()
                alert = DonationAlert(
                    title: String(localized: "settings.donations.thank_you_title"),
                    message: String(localized: "settings.donations.thank_you_message")
                )
            case .pending:
                alert = DonationAlert(
                    title: String(localized: "settings.donations.pending_title"),
                    message: String(localized: "settings.donations.pending_message")
                )
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            alert = DonationAlert(
                title: String(localized: "settings.donations.error_title"),
                message: String(localized: "settings.donations.purchase_error")
            )
        }
    }
}

struct DonationAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
