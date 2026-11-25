//
//  GroupDetailView.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 04/11/2026.
//
import SwiftUI
import SwiftData
import UIKit

struct GroupDetailView: View {
    let group: Group
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showDraw = false
    @State private var deletionError: String?
    @State private var activeSheet: GroupDetailSheet?

    private var persons: [Person] { group.persons.sorted { $0.name < $1.name } }

    var body: some View {
        List {
            Section {
                VStack(spacing: 14) {
                    Button {
                        activeSheet = .editGroup
                    } label: {
                        Avatar(
                            emoji: group.avatar,
                            tamano: 120,
                            imageName: availableGroupAvatars.contains(group.avatar) ? group.avatar : nil
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.personAvatarShadow, radius: 10, y: 5)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("groups.edit.title")

                    Text(group.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)

                    PriceTag(maxPrice: group.maxPrice)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            Section {
                ForEach(persons) { person in
                    ParticipantExclusionsCard(
                        person: person,
                        excludedPeople: persons.filter { person.noGift.contains($0.id) },
                        action: { openPersonEditor(person) }
                    )
                        .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                .onDelete { deletePersons(at: $0) }
            } header: {
                Text(localizedFormat(
                    NSLocalizedString("common.participants", comment: ""),
                    persons.count
                ))
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .textCase(nil)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 5)
            } 
        }
        .scrollContentBackground(.hidden)
        .background(Color.personScreenBackground.ignoresSafeArea())
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.accent)
                }
                .accessibilityLabel("common.back")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showDraw = true } label: {
                    Image(systemName: "gift")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.accent, in: Circle())
                }
                .accessibilityLabel("groups.draw_history")

            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { activeSheet = .newPerson } label: {
                    Image(systemName: "plus")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.accent, in: Circle())
                }
                .accessibilityLabel("people.action.add")

            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showDraw) { DrawListView(group: group) }
        .sheet(item: $activeSheet) { sheet in
            NavigationStack {
                switch sheet {
                case .editGroup:
                    EditGroupView(group: group)
                case .newPerson:
                    PersonView(group: group)
                case .editPerson(let selectedPerson):
                    PersonView(group: group, person: selectedPerson)
                        .id(selectedPerson.id)
                }
            }
        }
        .alert("groups.could_not_delete_participants", isPresented: deletionErrorIsPresented) {
            Button("common.ok", role: .cancel) { deletionError = nil }
        } message: {
            Text(LocalizedStringKey(deletionError ?? "draws.please_try_again"))
        }
    }

    private var deletionErrorIsPresented: Binding<Bool> {
        Binding(
            get: { deletionError != nil },
            set: { if !$0 { deletionError = nil } }
        )
    }

    private func openPersonEditor(_ person: Person) {
        // Dismiss any keyboard session before pushing another screen. A stale
        // remote text-input session can otherwise overlap the navigation change.
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
        activeSheet = .editPerson(person)
    }

    private func deletePersons(at offsets: IndexSet) {
        // Capture the selected models before changing the relationship-backed list.
        let selected = offsets.compactMap { index in
            persons.indices.contains(index) ? persons[index] : nil
        }
        guard !selected.isEmpty else { return }

        let selectedIDs = Set(selected.map(\.id))
        for participant in group.persons where !selectedIDs.contains(participant.id) {
            participant.noGift.removeAll { selectedIDs.contains($0) }
        }
        group.persons.removeAll { selectedIDs.contains($0.id) }
        selected.forEach { context.delete($0) }

        do {
            try context.save()
        } catch {
            context.rollback()
            deletionError = error.localizedDescription
        }
    }
}

private enum GroupDetailSheet: Identifiable {
    case editGroup
    case newPerson
    case editPerson(Person)

    var id: String {
        switch self {
        case .editGroup: "edit-group"
        case .newPerson: "new-person"
        case .editPerson(let person): "edit-person-\(person.id)"
        }
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
        Person(name: "Blas", avatar: "🎅"),
        Person(name: "María", avatar: "🎁"),
        Person(name: "Carlos", avatar: "⭐️"),
        Person(name: "Laura", avatar: "🔔")
    ]

    group.persons = persons

    container.mainContext.insert(group)

    return NavigationStack {
        GroupDetailView(group: group)
    }
    .modelContainer(container)
}
