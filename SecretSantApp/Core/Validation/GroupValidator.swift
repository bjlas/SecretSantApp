//
//  GroupValidator.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 05/11/2026.
//


import Foundation

struct GroupValidator {

    static func validateMaxPrice(
        _ maxPrice: String
    ) -> GroupValidationError? {

        let value = maxPrice.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !value.isEmpty else {
            return nil
        }

        guard let price = Decimal(
            string: value.replacingOccurrences(of: ",", with: ".")
        ), price > 0 else {
            return .invalidMaxPrice
        }

        return nil
    }
}
