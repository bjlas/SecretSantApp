import SwiftUI

struct ParticipantExclusionsCard: View {
    let person: Person
    let excludedPeople: [Person]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            FormSectionCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Avatar(emoji: person.avatar, tamano: 48, imageName: person.avatar)
                        Text(person.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }

                    if !excludedPeople.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "arrow.turn.down.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accent)
                                .padding(.top, 2)

                            VStack(alignment: .leading, spacing: 5) {
                                Text("people.exclusions.heading")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                VStack(alignment: .leading, spacing: 3) {
                                    ForEach(excludedPeople) { excludedPerson in
                                        HStack(spacing: 4) {
                                            Text(verbatim: "•")
                                            Text(excludedPerson.name)
                                        }
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    }
                                }
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.top, 10)
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(Color.personFieldBackground)
                                .frame(height: 1)
                        }
                    }
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
