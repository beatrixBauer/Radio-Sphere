import SwiftUI

struct StationCardView: View {
    let station: RadioStation

    var body: some View {
        HStack {
            // Hintergrund des Logos auf Weiß setzen
            ZStack {
                StationImageView(imageURL: station.imageURL)
                .frame(width: 100, height: 100)
                .shadow(color: .white, radius: 1)
            }
            .frame(width: 100, height: 100)

            // Text linksbündig mit gleicher Breite
            VStack(alignment: .leading) {
                Text(station.name.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2) // Nur eine Zeile für den Namen
                    .truncationMode(.tail) // Falls der Name zu lang ist, "..." anhängen

                Text(station.tags ?? "No tags")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1) // Maximal zwei Zeilen für die Tags
                    .truncationMode(.tail) // Falls die Tags zu lang sind, "..." anhängen
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }
        .padding()
        .frame(maxWidth: .infinity) // Maximale Breite nutzen
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.clear))
    }
}


#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        StationCardView(station: RadioStation(
            id: "1",
            name: "Blasmusikradio mit Bernd",
            url: "https://test-stream.com",
            country: "Netherlands",
            language: "niederländisch",
            tags: "blasmusik,folk,marsch,polka",
            imageURL: "https://test-image.com"
        ))
        .padding()
    }
}
