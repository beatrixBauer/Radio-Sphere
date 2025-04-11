//
//  AlbumArtworkView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.04.25.
//

/// lädt das Sender-Logo, falls vorhanden und nutzt andernfalls einen Platzhalter

import SwiftUI

// MARK: Erstellt die AlbumCover-Ansicht in der PlayerView

struct AlbumArtworkView: View {
    let artworkURL: URL?
    let frameWidth: CGFloat
    let frameHeight: CGFloat

    // Standardwerte: 300x300
    init(artworkURL: URL?, frameWidth: CGFloat = 300, frameHeight: CGFloat = 300) {
        self.artworkURL = artworkURL
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
    }

    var body: some View {
        ZStack {
            if let artworkURL = artworkURL {
                AsyncImage(url: artworkURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: frameWidth, height: frameHeight)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    case .success(let image):
                        image.resizable()
                            .scaledToFit()
                            .frame(width: frameWidth, height: frameHeight)
                            .cornerRadius(10)
                    case .failure:
                        Image("logo_square")
                            .resizable()
                            .scaledToFit()
                            .frame(width: frameWidth, height: frameHeight)
                            .opacity(0.6)
                    @unknown default:
                        Image("logo_square")
                            .resizable()
                            .scaledToFit()
                            .frame(width: frameWidth, height: frameHeight)
                            .opacity(0.6)
                    }
                }
            } else {
                Image("logo_square")
                    .resizable()
                    .scaledToFit()
                    .frame(width: frameWidth, height: frameHeight)
                    .opacity(0.6)
            }
        }
        .frame(width: frameWidth, height: frameHeight)
        .cornerRadius(10)
    }
}
