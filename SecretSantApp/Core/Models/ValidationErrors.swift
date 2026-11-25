//
//  models.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 02/11/2026.
//

import Foundation

enum SharedValidationError: Error {

    case nameRequired
    case nameTooShort

  
    var message: String {
        switch self {

        case .nameRequired:
            return String(localized: "validation.name_is_required")

        case .nameTooShort:
            return String(localized: "validation.person.name_too_short")
        }
    }
}

enum PersonValidationError: Error {

    case emailRequired
    case emailInvalid

    case phoneRequired
    case phoneInvalid

    var message: String {
        switch self {

        case .emailRequired:
            return String(localized: "validation.email_is_required")

        case .emailInvalid:
            return String(localized: "validation.enter_a_valid_email_address")

        case .phoneRequired:
            return String(localized: "validation.phone_number_is_required")

        case .phoneInvalid:
            return String(localized: "validation.person.invalid_phone")
        }
    }
}


enum GroupValidationError: LocalizedError, Equatable {
    case nameRequired
    case nameTooShort
    case invalidMaxPrice

    
    
    var message: String {
        switch self {

        case .nameRequired:
            return String(localized: "validation.name_is_required_2")
        case .nameTooShort:
            return String(localized: "validation.group.name_too_short")
        case .invalidMaxPrice:
            return String(localized: "validation.group.invalid_price")
        }
    }
    

}
