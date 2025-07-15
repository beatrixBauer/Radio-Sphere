//
//  StationCardView.swift
//  Radio_Sphere
//

import SwiftUI

// MARK: Definiert das Aussehen der Stationen in der Listendarstellung mit Radiostationen

struct StationCardView: View {
    let station: RadioStation

    var body: some View {
        HStack {
            // Hintergrund des Logos, da einige Senderlogos transparent sind
            ZStack {
                StationImageView(imageURL: station.imageURL)
                .frame(width: 100, height: 100)
                .shadow(color: .white, radius: 1)
            }
            .frame(width: 100, height: 100)

            // Text linksbündig mit gleicher Breite
            VStack(alignment: .leading) {
                Text(station.decodedName.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2) // Zwei Zeilen für den Namen
                    .truncationMode(.tail) // Falls der Name zu lang ist, "..." anhängen

                Text(station.decodedTags ?? "No tags")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1) // Maximal eine Zeile für die Tags
                    .truncationMode(.tail) // Falls die Tags zu lang sind, "..." anhängen
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }
        .padding()
        .frame(maxWidth: .infinity) // Maximale Breite nutzen
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.clear))
    }
}
