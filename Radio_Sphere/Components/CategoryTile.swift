//
//  CategoryTile.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 12.04.25.
//

import SwiftUI

// MARK: Ansicht Kategorien-Kachel

struct CategoryTile: View {
    let title: String
    let iconName: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.darkblue.opacity(0.4), Color.midblue.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

            VStack(spacing: 8) {
                // hier entscheidet sich, ob Asset oder SF Symbol
                if UIImage(named: iconName) != nil {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                        .foregroundColor(.white) // template‑Mode, falls gewünscht
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                }

                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .frame(height: 120)
    }
}
