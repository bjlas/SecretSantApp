//
//  NewGroupView.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 03/11/2026.
//
import SwiftUI
import SwiftData


struct EditGroupView: View {
    let group: Group?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: GroupViewModel

    init(group: Group? = nil) {
        self.group = group
        
        let vm = GroupViewModel()
        
        if let group {
            vm.loadGroup(group)
        }
        
        _viewModel = State(initialValue: vm)
    }

    private var service: GroupService {
        GroupService(context: modelContext)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            ZStack {
                Color.personScreenBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 60) {

                        EditableAvatar(
                            emoji: viewModel.form.avatar,
                            size: 200,
                            imageName: viewModel.form.avatar,
                            accessibilityLabel: "groups.change_group_avatar",
                            pickerTitle: "groups.group_avatar",
                            pickerSubtitle: "groups.avatar.hint",
                            availableAvatars: availableGroupAvatars,
                            selection: $viewModel.form.avatar
                        )
                        
                        
                        FormSectionCard {
                            VStack(alignment: .leading, spacing: 16) {
                                FormSectionHeading(
                                    title: "groups.group_details",
                                    subtitle: "groups.set_the_group_name_and_gift_budget"
                                )

                                VStack(spacing: 10) {
                                    PersonInputShell(icon: "person.2", error: viewModel.nameError?.message) {
                                        TextField("groups.group_name", text: $viewModel.form.name)
                                            .textContentType(.name)
                                            .textInputAutocapitalization(.words)
                                    }

                                    PersonInputShell(icon: "eurosign", error: viewModel.maxPriceError?.message) {
                                        TextField("groups.maximum_price_optional", text: $viewModel.form.maxPriceText)
                                            .keyboardType(.decimalPad)
                                    }
                                }
                            }
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
                    PrimaryButton(title: group == nil ? "groups.create_group" : "people.save_changes") {
                        viewModel.saveGroup(group: group, service: service)
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
            .navigationTitle(group == nil ? "groups.create.title" : "groups.edit.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .onChange(of: viewModel.form.name) {
                if viewModel.hasSubmitted { viewModel.validateName() }
            }
            .onChange(of: viewModel.form.maxPriceText) {
                if viewModel.hasSubmitted { viewModel.validateMaxPrice() }
            }
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
            }
        }
    }
}

#Preview {
    EditGroupView()
}
