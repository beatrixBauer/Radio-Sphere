//
//  StationDetailView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 02.04.25.
//

import SwiftUI

// MARK: Ansicht des Players
// Anzeige von Albumcover, Songtitel, Künstler etc.

struct PlayerView: View {
    @State var station: RadioStation
    let filteredStations: [RadioStation]
    let categoryTitle: String
    let isSheet: Bool
    @StateObject private var manager = StationsManager.shared
    @Environment(\.dismiss) private var dismiss

    init(station: RadioStation, filteredStations: [RadioStation], categoryTitle: String, isSheet: Bool) {
        _station = State(initialValue: station)
        self.filteredStations = filteredStations
        self.categoryTitle = categoryTitle
        self.isSheet = isSheet
    }

    var body: some View {

        GeometryReader { geometry in
            let isCompact = geometry.size.height < 650
            VStack {
                if isSheet {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.down.circle")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(20)
                        Spacer()
                    }
                }

                HStack {
                    // Sendername: Schriftgröße wird dynamisch gewählt
                    MarqueeText(text: station.decodedName,
                                font: isCompact ? .headline : .title,
                                speed: 5, delay: 1)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)

                    Spacer()

                    if manager.isPlaying {
                        NowPlayingBarView()
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "waveform")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, isCompact ? 20 : 40)
                .padding(.bottom, isCompact ? 10 : 20)

                ZStack(alignment: .bottomTrailing) {
                    // AlbumArtworkView aufrufen und die Größe anpassen:
                    AlbumArtworkView(artworkURL: manager.currentArtworkURL,
                                     frameWidth: isCompact ? 250 : 300,
                                     frameHeight: isCompact ? 250 : 300)

                    // Neuen ITunesLinkButton einfügen – vorausgesetzt, du hast bereits die URL (trackViewUrl) ermittelt
                    if let trackUrl = manager.currentTrackURL {
                        ITunesLinkButton(trackUrl: trackUrl)
                            .padding(.top, 8)
                            .offset(x: 15, y: 15)
                    }
                }
                .padding(.bottom, 10)

                VolumeSliderView()

                // Künstler und aktueller Song: Schriftgröße wird angepasst
                Text(manager.currentArtist.fixEncoding())
                    .font(isCompact ? .title : .title2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(manager.currentTrack.fixEncoding())
                    .font(isCompact ? .title : .title2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)

                HStack(spacing: isCompact ? 30 : 50) {
                    // Previous-Button mit angepasster Größe
                    ActionButton(systemName: "backward.fill", buttonSize: isCompact ? 25 : 28) {
                        manager.setPrevious()
                    }

                    // Play/Pause-Button bleibt wie gehabt (hier definieren wir die Größe direkt)
                    Button {
                        if manager.isPlaying && manager.currentStation == station {
                            manager.pausePlayback()
                        } else {
                            manager.set(station: station)
                        }
                    } label: {
                        Image(systemName: manager.isPlaying && manager.currentStation == station ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: isCompact ? 30 : 40, height: isCompact ? 30 : 40)
                            .foregroundColor(manager.isPlaying && manager.currentStation?.id == station.id ? Color("goldorange") : .gray)
                            .shadow(radius: 4)
                    }

                    // Next-Button mit angepasster Größe
                    ActionButton(systemName: "forward.fill", buttonSize: isCompact ? 25 : 28) {
                        manager.setNext()
                    }
                }
                .padding(.vertical, isCompact ? 10 : 20)

                HStack {
                    SleepTimerView(iconSize: isCompact ? 25 : 28)
                    Spacer()
                    LikeButton(station: station, buttonSize: isCompact ? 25 : 28)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, isCompact ? 30 : 40)
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .padding(.horizontal, 10)
            .padding(.bottom, 20)
            .applyBackgroundGradient()
            .preferredColorScheme(.dark)
            .onAppear {
                manager.isInPlayerView = true
                manager.prepareForPlayback(station: station, in: filteredStations)
            }
            .onDisappear {
                manager.isInPlayerView = false
            }
            .onChange(of: manager.currentStation) { newStation in
                if let newStation = newStation, station.id != newStation.id {
                    station = newStation
                    print("PlayerView aktualisiert: \(station.decodedName)")
                }
            }
        }
    }
}
