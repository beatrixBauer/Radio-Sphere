//
//  StationDetailView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.02.25.
//

import SwiftUI

struct PlayerView: View {
    let station: RadioStation
    @StateObject private var manager = StationsManager.shared

    var body: some View {
        VStack {
            // 🎨 Albumcover oder Platzhalter
            if let image = manager.currentArtwork {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .cornerRadius(20)
            } else {
                StationImageView(imageURL: station.imageURL)
                    .frame(width: 150, height: 150)
                    .cornerRadius(20)
            }

            // 📻 Sendername & Land
            Text(station.name)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 10)

            Text(station.country)
                .font(.subheadline)
                .foregroundColor(.gray)

            // 🎵 Aktuell gespielter Song & Künstler
            VStack {
                Text(manager.currentTrack)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                Text(manager.currentArtist)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()

            // 🔘 Play-Button zum Starten des Streams
            Button(action: { manager.set(station: station) }) {
                Image(systemName: "play.fill")
                    .font(.largeTitle)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(.top, 30)
        }
        .navigationTitle("Player")
        .onAppear {
            manager.set(station: station)
        }
    }
}

