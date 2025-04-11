//
//  LikeButton.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 15.04.25.
//

import SwiftUI

struct LikeButton: View {
    @ObservedObject var favoritesManager = FavoritesManager.shared
    var station: RadioStation
    var buttonSize: CGFloat = 30  // Standardgröße

    var body: some View {
        Button(action: {
            if favoritesManager.isFavorite(station: station) {
                favoritesManager.removeFavorite(station: station)
            } else {
                favoritesManager.addFavorite(station: station)
            }
        }) {
            Image(systemName: favoritesManager.isFavorite(station: station) ? "heart.fill" : "heart")
                .foregroundColor(favoritesManager.isFavorite(station: station) ? .goldorange : .gray)
                .font(.system(size: buttonSize))
        }
    }
}
