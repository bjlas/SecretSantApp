//
//  theme.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 02/11/2026.
//
import SwiftUI


struct PriceTag: View {
    let maxPrice: Decimal?

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "tag.fill").foregroundStyle(Color.accent)
            Text(textPrice(maxPrice))
        }
        .font(.subheadline.weight(.medium))
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Color.accentSoft, in: Capsule())
    }
}
