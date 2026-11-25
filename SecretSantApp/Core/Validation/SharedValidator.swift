
//
//  Validators.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 05/11/2026.
//


import Foundation

struct SharedValidator {

    // MARK: - Max Price
    static func validateName(
        _ name: String
    ) -> SharedValidationError? {

        let value = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !value.isEmpty else {
            return .nameRequired
        }

        guard value.count >= 3 else {
            return .nameTooShort
        }

        return nil
    }
}
