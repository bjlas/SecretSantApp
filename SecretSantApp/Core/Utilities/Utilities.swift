//
//  Utilities.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 08/11/2026.
//

import SwiftUI

func formatPrice(_ price: Decimal) -> String {
    price.formatted(
        .currency(code: "EUR").precision(.fractionLength(0...2))
    )
}

func textPrice(_ price: Decimal?) -> String {
    guard let price else { return String(localized: "price.no_limit") }
    return localizedFormat(NSLocalizedString("common.max", comment: ""), formatPrice(price))
}

func localizedFormat(_ template: String, _ arguments: CVarArg...) -> String {
    String(format: template, locale: Locale.current, arguments: arguments)
}


