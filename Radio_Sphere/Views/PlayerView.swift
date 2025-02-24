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
        VStack (spacing: 20) {
            
            // Sendername
            Text(station.name)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            // Albumcover (Größe ist in AlbumArtworkView definiert)
            AlbumArtworkView(artworkURL: manager.currentArtworkURL)
            
            // Lautstärkeregler
            VolumeSliderView()
            
            // Künstler
            Text(manager.currentArtist.fixEncoding())
                .font(.title2)
                .fontWeight(.semibold)
            
            // Aktueller Songtitel
            Text(manager.currentTrack.fixEncoding())
                .font(.title3)
                .italic()
            
            // Play/Pause-Button
            Button(action: {
                if manager.isPlaying && manager.currentStation == station {
                    manager.pausePlayback()
                } else {
                    manager.set(station: station)
                }
            }) {
                Image(systemName: manager.isPlaying && manager.currentStation == station ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .shadow(radius: 4)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .preferredColorScheme(.dark)
        .padding()
        .onAppear {
            if manager.currentStation != station {
                manager.set(station: station)
            }
        }
        .onReceive(manager.$currentArtworkURL) { _ in
            print("Albumcover aktualisiert: \(String(describing: manager.currentArtworkURL))")
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(station: RadioStation(
            name: "Hit Radio Tom",
            url: "https://hitradiotom.stream.laut.fm/hitradiotom?t302=2025-02-21_21-39-18&uuid=59249936-c7df-45c5-910b-f9954ea714ab",
            codec: "MP3"
        ))
    }
}






