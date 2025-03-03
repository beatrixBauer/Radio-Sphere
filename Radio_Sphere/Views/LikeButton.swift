import SwiftUI

struct LikeButton: View {
    @ObservedObject var favoritesManager = FavoritesManager.shared
    var station: RadioStation

    var body: some View {
        Button(action: {
            if favoritesManager.isFavorite(station: station) {
                favoritesManager.removeFavorite(station: station)
            } else {
                favoritesManager.addFavorite(station: station)
            }
        }) {
            Image(systemName: favoritesManager.isFavorite(station: station) ? "heart.fill" : "heart")
                .foregroundColor(favoritesManager.isFavorite(station: station) ? .red : .gray)
                .font(.system(size: 25))
        }
    }
}
