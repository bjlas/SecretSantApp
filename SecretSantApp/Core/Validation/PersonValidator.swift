//
//  PersonValidator.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 05/11/2026.
//


import Foundation

struct PersonValidator {

    static func validateEmail(
        _ email: String
    ) -> PersonValidationError? {

        let value = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !value.isEmpty else {
            return .emailRequired
        }

        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

        guard value.range(
            of: pattern,
            options: .regularExpression
        ) != nil else {
            return .emailInvalid
        }

        return nil
    }

    static func validatePhone(
        _ phone: String
    ) -> PersonValidationError? {

        let value = phone.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !value.isEmpty else {
            return .phoneRequired
        }

        let allowedCharacters = Set("0123456789+(). -")

        guard value.allSatisfy({
            allowedCharacters.contains($0)
        }) else {
            return .phoneInvalid
        }

        let digits = value.filter {
            $0.isASCII && $0.isNumber
        }

        guard (9...15).contains(digits.count) else {
            return .phoneInvalid
        }

        return nil
    }
}
