//
//  inputs.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 02/11/2026.
//
import SwiftUI


struct PersonInputShell<Content: View>: View {
    let icon: String
    let error: String?
    let content: Content

    init(icon: String, error: String?, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.error = error
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 11) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.accent.opacity(0.8))
                    .frame(width: 20)
                content
                    .font(.body)
                    .padding(.vertical, 15)
            }
            .padding(.horizontal, 14)
            .background(Color.personFieldBackground, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(error == nil ? Color.clear : Color.personValidation.opacity(0.45), lineWidth: 1)
            }

            if let error {
                ValidationMessage(text: error)
                    .padding(.leading, 8)
            }
        }
    }
}
