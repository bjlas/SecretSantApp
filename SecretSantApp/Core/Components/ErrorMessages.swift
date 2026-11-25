//
//  ErrorMessages.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 23/11/2026.
//
import SwiftUI

struct ValidationMessage: View {
    let text: String

    var body: some View {
        Text(LocalizedStringKey(text))
            .font(.caption)
            .foregroundStyle(.red)
    }
}
