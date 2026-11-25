//
//  GroupViewModel.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 05/11/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class GroupViewModel {
    var form = GroupFormModel()
    
    var nameError: SharedValidationError?
    var maxPriceError: GroupValidationError?

    var serviceError: String?
    
    var hasSubmitted = false
    var isLoading = false
    var registrationCompleted = false
    
    func validateName() {
        nameError = SharedValidator.validateName(
            form.name
        )
    }

    func validateMaxPrice() {
        maxPriceError = GroupValidator.validateMaxPrice(
            form.maxPriceText
        )
    }
    
    @discardableResult
    func validateForm() -> Bool {

        hasSubmitted = true

        validateName()
        validateMaxPrice()

        return nameError == nil &&
               maxPriceError == nil
    }


    func saveGroup(group: Group?, service: GroupService) {
  
        guard !isLoading else { return }
        guard validateForm() else { return }

        isLoading = true
        serviceError = nil

        defer {
            isLoading = false
        }

        do {
            try service.saveGroup(
                name: form.name.trimmingCharacters(in: .whitespacesAndNewlines),
                maxPrice: form.maxPrice,
                avatar: form.avatar,
                editing: group
            )
            registrationCompleted = true
        } catch {
            serviceError = error.localizedDescription
        }
    }

    func loadGroup(_ group: Group) {

        form.name = group.name
        form.maxPriceText = group.maxPrice.map { NSDecimalNumber(decimal: $0).stringValue } ?? ""
        form.avatar = availableGroupAvatars.contains(group.avatar) ? group.avatar : (availableGroupAvatars.randomElement() ?? "GroupAvatar01")


        clearErrors()

        hasSubmitted = false
        registrationCompleted = false
    }
    
    func resetForm() {

        form = GroupFormModel()

        clearErrors()

        hasSubmitted = false
        registrationCompleted = false
    }
    
    private func clearErrors() {

        nameError = nil
        maxPriceError = nil

    }
}
