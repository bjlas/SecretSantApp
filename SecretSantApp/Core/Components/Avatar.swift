
//
//  theme.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 02/11/2026.
//
import SwiftUI
import Foundation


let availablePersonAvatars = (1...15).map { String(format: "AvatarPerson%02d", $0) }

struct Avatar: View {
    let emoji: String
    var tamano: CGFloat = 44
    var imageName: String? = nil

    var body: some View {
        SwiftUI.Group {
            if let imageName,
                      availablePersonAvatars.contains(imageName) || availableGroupAvatars.contains(imageName) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(emoji)
                    .font(.system(size: tamano * 0.5))
                    .frame(width: tamano, height: tamano)
                    .background(Color.accentSoft)
            }
        }
        .frame(width: tamano, height: tamano)
        .clipShape(Circle())
    }
}

struct EditableAvatar: View {
    let emoji: String
    let size: CGFloat
    let imageName: String
    let accessibilityLabel: LocalizedStringKey
    let pickerTitle: LocalizedStringKey
    let pickerSubtitle: LocalizedStringKey
    let availableAvatars: [String]
    @Binding var selection: String

    @State private var showPicker = false

    var body: some View {
        Button {
            showPicker = true
        } label: {
            Avatar(emoji: emoji, tamano: size, imageName: imageName)
                .clipShape(Circle())
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.personSurface, Color.accent)
                        .background(Color.personScreenBackground, in: Circle())
                        .offset(x: 3, y: 3)
                }
                .shadow(color: Color.personAvatarShadow, radius: 10, y: 5)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .accessibilityLabel(Text(accessibilityLabel))
        .sheet(isPresented: $showPicker) {
            AvatarPickerSheet(
                title: pickerTitle,
                subtitle: pickerSubtitle,
                avatars: availableAvatars,
                selection: $selection
            )
        }
    }
}

struct AvatarPickerSheet: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let avatars: [String]
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 18) {
                    ForEach(avatars, id: \.self) { avatar in
                        Button {
                            selection = avatar
                            dismiss()
                        } label: {
                            Image(avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 78, height: 78)
                                .clipShape(Circle())
                                .overlay {
                                    Circle().stroke(selection == avatar ? Color.accent : .clear, lineWidth: 3)
                                }
                                .padding(3)
                                .background(selection == avatar ? Color.accentSoft : .clear, in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text(localizedFormat(
                            NSLocalizedString("common.select_avatar", comment: ""),
                            String(avatar.suffix(2))
                        )))
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(24)
            .navigationTitle(Text(title))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.done") { dismiss() }
                        .foregroundStyle(Color.accent)
                }
            }
        }
        .presentationDetents([.large])
    }
}
