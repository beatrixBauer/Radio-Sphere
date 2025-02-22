import SwiftUI

struct AlbumArtworkView: View {
    let artworkURL: URL?

    var body: some View {
        AsyncImage(url: artworkURL) { phase in
            if let image = phase.image {
                image.resizable().scaledToFit()
            } else {
                Image(systemName: "music.note") // Fallback-Symbol
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 200, height: 200)
        .cornerRadius(10)
    }
}
