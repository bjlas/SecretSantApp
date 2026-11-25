//
//  GroupListView.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 02/11/2026.
//

import SwiftUI
import SwiftData

struct GroupListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Group.name) private var groups: [Group]

    @State private var showNewGroup = false
    @State private var showSettings = false
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            
            List {
                ForEach(groups) { group in
                    Button {
                        navigationPath.append(group)
                    } label: {
                        FormSectionCard {
                            HStack(spacing: 14) {
                                Avatar(
                                    emoji: group.avatar,
                                    tamano: 48,
                                    imageName: availableGroupAvatars.contains(group.avatar) ? group.avatar : nil
                                )

                                Text(group.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                }
                .onDelete { offsets in
                    for i in offsets {
                        context.delete(groups[i])
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.personScreenBackground.ignoresSafeArea())
            .overlay {
                if groups.isEmpty {
                    ContentUnavailableView(
                        "groups.empty.title",
                        systemImage: "gift",
                        description: Text("groups.empty.hint")
                    )
                }
            }
            .navigationTitle("groups.title")
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(for: Group.self) {
                GroupDetailView(group: $0)
            }
            .toolbar {
                
                ToolbarItem(placement: .topBarTrailing) {
                    
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.accent, in: Circle())
                    }
                    .accessibilityLabel("groups.google_settings")
             
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button() {
                        showNewGroup = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.accent, in: Circle())
                        
                    }
                    .accessibilityLabel("groups.action.add")
                }

            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showNewGroup) {
                EditGroupView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Group.self, Person.self, Draw.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let sampleGroups = [
        Group(name: "Navidad 2026", maxPrice: 30, avatar: "🎄"),
        Group(name: "Amigos de la uni", maxPrice: 25, avatar: "🎁"),
        Group(name: "Familia Gimeno", avatar: "⭐️")
    ]

    sampleGroups.forEach { container.mainContext.insert($0) }

    return GroupListView()
        .modelContainer(container)
}
