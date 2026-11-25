//
//  PersonView.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 05/11/2026.
//


import SwiftUI
import SwiftData

struct PersonView: View {
    let group: Group
    let person: Person?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PersonViewModel
    @State private var showAgenda = false
    
    init(group: Group, person: Person? = nil) {
        
        self.group = group
        self.person = person
        
        let vm = PersonViewModel(group: group)
        
        if let person {
            vm.loadPerson(person)
        }
        
        _viewModel = State(initialValue: vm)
    }
    
    private var personService: PersonService {
        PersonService(context: modelContext)
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        let eligiblePeople = viewModel.freePersons(excluding: person)
        ZStack {
            Color.personScreenBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    EditableAvatar(
                        emoji: viewModel.form.avatar,
                        size: 150,
                        imageName: viewModel.form.avatar,
                        accessibilityLabel: "people.change_avatar",
                        pickerTitle: "people.change_avatar",
                        pickerSubtitle: "people.avatar.hint",
                        availableAvatars: availablePersonAvatars,
                        selection: $viewModel.form.avatar
                    )
                    contactSection(viewModel: viewModel)
                    notificationSection(viewModel: viewModel)
                    exclusionsSection(viewModel: viewModel, eligiblePeople: eligiblePeople)

                    if let error = viewModel.serviceError {
                        ValidationMessage(text: error)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color.personSurface, in: RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
        
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 8) {
                PrimaryButton(title: viewModel.isLoading ? "people.saving" : (person == nil ? "people.create.action" : "people.save_changes")) {
                    viewModel.register(person: person, service: personService)
                    if viewModel.registrationCompleted { dismiss() }
                }
                
                SecondaryButton(title: "common.cancel") {
                    dismiss()
                }

            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 6)
            .background(Color.personScreenBackground)
        }
        
        .navigationTitle(person == nil ? "people.create.title" : "people.edit.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.accent)
                }
                .accessibilityLabel("common.back")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAgenda = true } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.accent)
                }
                .accessibilityLabel("people.import_from_contacts")
            }
        }
        .onChange(of: viewModel.form.name) {
            if viewModel.hasSubmitted { viewModel.validateName() }
        }
        .onChange(of: viewModel.form.email) {
            if viewModel.hasSubmitted { viewModel.validateEmail() }
        }
        .onChange(of: viewModel.form.phone) {
            if viewModel.hasSubmitted { viewModel.validatePhone() }
        }
        .onChange(of: viewModel.form.notificationChannel) {
            if viewModel.hasSubmitted { viewModel.validateNotificationChannel() }
        }
        .sheet(isPresented: $showAgenda) {
            ContactPickerView { contact in
                if let contact {
                    viewModel.copyContact(
                        name: contact.name,
                        phone: contact.phone,
                        email: contact.email
                    )
                }
            }
            .ignoresSafeArea()
        }
    }

    private func contactSection(viewModel: PersonViewModel) -> some View {
        FormSectionCard {
            VStack(alignment: .leading, spacing: 14) {
                FormSectionHeading(title: "people.contact.title", subtitle: "people.contact.hint")

                VStack(spacing: 10) {
                    PersonInputShell(icon: "person", error: viewModel.nameError?.message) {
                        TextField("people.name.placeholder", text: $viewModel.form.name)
                            .textContentType(.name)
                            .textInputAutocapitalization(.words)
                    }

                    PersonInputShell(icon: "envelope", error: viewModel.emailError?.message) {
                        TextField("people.email.placeholder", text: $viewModel.form.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }

                    PersonInputShell(icon: "phone", error: viewModel.phoneError?.message) {
                        TextField("people.phone.placeholder", text: $viewModel.form.phone)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                    }
                }
            }
        }
    }

    private func notificationSection(viewModel: PersonViewModel) -> some View {
        FormSectionCard {
            VStack(alignment: .leading, spacing: 14) {
                FormSectionHeading(title: "people.send_notification_by", subtitle: "people.choose_how_to_contact_this_person")
                HStack(spacing: 10) {
                    ForEach(NotificationChannel.allCases) { channel in
                        Button {
                            viewModel.form.notificationChannel = channel
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: channel == .email ? "envelope.fill" : "message.fill")
                                Text(channel == .email ? "people.channel.email" : "people.channel.sms")
                            }
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .foregroundStyle(viewModel.form.notificationChannel == channel ? Color.accent : Color.secondary)
                            .background(viewModel.form.notificationChannel == channel ? Color.accentSoft : Color.personFieldBackground, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func exclusionsSection(viewModel: PersonViewModel, eligiblePeople: [Person]) -> some View {
        FormSectionCard {
            VStack(alignment: .leading, spacing: 14) {
                FormSectionHeading(title: "people.gift_exclusions", subtitle: "people.exclusions.hint")
                if eligiblePeople.isEmpty {
                    Text("people.exclusions.empty")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color.personFieldBackground, in: RoundedRectangle(cornerRadius: 16))
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 9) {
                        ForEach(eligiblePeople) { otherPerson in
                            PersonExclusionOption(
                                person: otherPerson,
                                isSelected: viewModel.isExcludedFromGift(to: otherPerson.id),
                                onTap: { viewModel.toggleNoGift(otherPerson.id) }
                            )
                        }
                    }
                }
            }
        }
    }

}

private struct PersonExclusionOption: View {
    let person: Person
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(person.name).lineLimit(1)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.accent : Color.gray.opacity(0.4))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(isSelected ? Color.accentSoft : Color.personFieldBackground, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    
    
    let container = try! ModelContainer(
        for: Group.self, Person.self, Draw.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let group = Group(
        name: "Navidad 2026",
        maxPrice: 30
    )
    
    group.avatar = "🎄"
    
    let persons = [
        Person(name: "Blas", avatar: "AvatarPerson01"),
        Person(name: "María", avatar: "AvatarPerson02"),
        Person(name: "Carlos", avatar: "AvatarPerson03"),
        Person(name: "Laura", avatar: "AvatarPerson04")
    ]
    
    group.persons = persons
    
    container.mainContext.insert(group)
    
    return NavigationStack {
        PersonView(group: group, person: persons[0])
    }
    .modelContainer(container)
    
}
