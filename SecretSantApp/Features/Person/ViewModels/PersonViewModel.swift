//
//  PersonViewModel.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 05/11/2026.
//


import Foundation
import Observation


@MainActor
@Observable
final class PersonViewModel {

    let group: Group

    var form = PersonFormModel()

    var nameError: SharedValidationError?
    var emailError: PersonValidationError?
    var phoneError: PersonValidationError?

    var serviceError: String?

    var hasSubmitted = false
    var isLoading = false
    var registrationCompleted = false

    init(group: Group) {
        self.group = group
    }

    // MARK: - Validate

    func validateName() {
        nameError = SharedValidator.validateName(form.name)
    }

    func validateEmail() {
        emailError = form.notificationChannel == .email ? PersonValidator.validateEmail(form.email) : nil
    }

    func validatePhone() {
        phoneError = form.notificationChannel == .sms ? PersonValidator.validatePhone(form.phone) : nil
    }

    @discardableResult
    func validateForm() -> Bool {

        hasSubmitted = true

        validateName()
        validateEmail()
        validatePhone()

        return nameError == nil &&
               emailError == nil &&
               phoneError == nil
    }

    // MARK: - Register

    func register(
        person: Person?,
        service: PersonService
    ) {

        guard !isLoading else { return }
        guard validateForm() else { return }

        isLoading = true
        serviceError = nil

        defer {
            isLoading = false
        }

        do {

            try service.savePerson(
                form: form,
                group: group,
                editing: person
            )

            registrationCompleted = true

        } catch {

            serviceError = error.localizedDescription
        }
    }

    // MARK: - Load Person

    func loadPerson(_ person: Person) {

        form.name = person.name
        form.email = person.email
        form.notificationChannel = NotificationChannel(rawValue: person.notificationChannel) ?? .email
        form.phone = person.phone
        form.noGift = person.noGift
        form.avatar = person.avatar
        
        clearErrors()

        hasSubmitted = false
        registrationCompleted = false
    }

    // MARK: - Reset

    func resetForm() {

        form = PersonFormModel()

        clearErrors()

        hasSubmitted = false
        registrationCompleted = false
    }

    private func clearErrors() {

        nameError = nil
        emailError = nil
        phoneError = nil
        serviceError = nil
    }
    
    func freePersons(excluding person: Person?) -> [Person] {
        group.persons
            .filter { $0.id != person?.id }
            .sorted { $0.name < $1.name }
    }
    
    func toggleNoGift(_ id: UUID) {
        if form.noGift.contains(id) {
            form.noGift.removeAll { $0 == id }
        } else {
            form.noGift.append(id)
        }
    }

    func isExcludedFromGift(to personID: UUID) -> Bool {
        form.noGift.contains(personID)
    }
    
    func copyContact(name: String?, phone: String?, email: String?) {
        form.name = name ?? form.name
        form.phone = phone ?? form.phone
        form.email = email ?? form.email
        form.avatar = availablePersonAvatars.randomElement() ?? "AvatarPerson01"
    }

    func validateNotificationChannel() {
        validateEmail()
        validatePhone()
    }
    
}
