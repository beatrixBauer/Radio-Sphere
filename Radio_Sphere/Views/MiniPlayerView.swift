//
//  MiniPlayerView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 20.04.25.
//

import SwiftUI

struct MiniPlayerView: View {
    @ObservedObject var manager = StationsManager.shared
    var onTap: () -> Void
    @State private var showRemainingTime = false

    var body: some View {
        if manager.isPlaying, !manager.isInPlayerView, let station = manager.currentStation {
            HStack {
                // Album-/Senderbild (immer sichtbar)
                AsyncImage(url: manager.currentArtworkURL) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "music.note")
                        .resizable()
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Songtitel und Künstler
                VStack(alignment: .leading, spacing: 2) {
                    Text(manager.currentTrack.isEmpty ? "Live-Übertragung" : manager.currentTrack)
                        .font(.headline)
                        .lineLimit(1)
                    Text(manager.currentArtist.isEmpty ? station.decodedName : manager.currentArtist)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                .padding(.leading, 8)
                
                Spacer()

                // Sleep Timer Icon mit temporärer Anzeige des Countdowns
                 if manager.isSleepTimerActive {
                     Button(action: {
                         withAnimation {
                             showRemainingTime.toggle()
                         }
                         // Blende den Countdown nach 3 Sekunden automatisch wieder aus:
                         DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                             withAnimation {
                                 showRemainingTime = false
                             }
                         }
                     }) {
                         ZStack {
                             Image(systemName: "timer.circle.fill")
                                 .resizable()
                                 .frame(width: 23, height: 23)
                                 .foregroundColor(.goldorange)
                             if showRemainingTime, let remaining = manager.sleepTimerRemainingTime {
                                 Text(remaining.asMMSS)
                                     .font(.caption2)
                                     .foregroundColor(.white)
                                     .padding(4)
                                     .background(Color.black.opacity(0.7))
                                     .clipShape(Capsule())
                                     .offset(y: -30) // Der Text erscheint oberhalb des Icons
                             }
                         }
                     }
                     .padding(.trailing, 10)
                 }

                // Pause-Button
                Button(action: {
                    manager.pausePlayback()
                }) {
                    Image(systemName: "pause.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
            }
            .padding()
            .background(
                ZStack {
                    Color.gray
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.9),
                                                    Color("darkblue").opacity(0.7),
                                                    Color("darkred").opacity(0.4)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding(10)
            .frame(minHeight: 80)
            .contentShape(Rectangle()) // Ganze Fläche tappable
            .onTapGesture {
                print("MiniPlayer tapped")
                onTap()
            }
        }
    }
    
    // Hilfsfunktion zur Formatierung von Sekunden in mm:ss
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
}
