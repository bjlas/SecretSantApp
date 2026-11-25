
import Foundation

let availableGroupAvatars = (1...6).map { String(format: "AvatarGroup%02d", $0) }

struct GroupFormModel {
    var name = ""
    var maxPriceText = ""
    var avatar = availableGroupAvatars.randomElement() ?? "AvatarGroup01"

    var maxPrice: Decimal? {
        let text = maxPriceText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else { return nil }

        return Decimal(string: text, locale: .current)
    }
}
