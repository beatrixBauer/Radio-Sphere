//
//  AlbumArtworkView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.02.25.
//

import SwiftUI

struct AlbumArtworkView: View {
    let artworkURL: URL?
    let frameWidth: CGFloat = 300
    let frameHeight: CGFloat = 300
    
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
                        Image("stationPlaceholder").resizable().scaledToFit().opacity(0.5)

                    @unknown default:
                        Image("albumPlaceholder").resizable().scaledToFit().opacity(0.5)
                    }
                }
            } else {
                Image("albumPlaceholder").resizable().scaledToFit().opacity(0.5)
            }
        }
        .frame(width: frameWidth, height: frameHeight)
        .cornerRadius(10)
    }

}


