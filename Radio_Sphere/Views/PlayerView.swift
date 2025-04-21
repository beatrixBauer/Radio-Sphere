//
//  StationDetailView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 02.04.25.
//

import SwiftUI

// MARK: Ansicht des Players
// Anzeige von Albumcover, Songtitel, Künstler etc.

import SwiftUI

struct PlayerView: View {
    @State var station: RadioStation
    let filteredStations: [RadioStation]
    let categoryTitle: String
    let isSheet: Bool
    @StateObject private var manager = StationsManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass)   private var vSizeClass   // .regular | .compact
    @Environment(\.horizontalSizeClass) private var hSizeClass   // .regular | .compact

    init(station: RadioStation,
         filteredStations: [RadioStation],
         categoryTitle: String,
         isSheet: Bool) {
        _station = State(initialValue: station)
        self.filteredStations = filteredStations
        self.categoryTitle = categoryTitle
        self.isSheet = isSheet
    }

    var body: some View {
        GeometryReader { geo in
            let hasNotch = UIDevice.current.hasNotchAtWindowLevel
            let isMini  = UIDevice.current.isMiniNotch
            let isMedium = UIDevice.current.isMediumNotch
            //let isLarge = UIDevice.current.isLargeNotch
            let isCompact = hSizeClass == .compact && geo.size.height < 750
            let horizontalPadding = isCompact ? 20.0 : 30.0
            let bottomPadding     = isCompact ? 10.0 : 20.0
            let verticalSpacing: CGFloat =  !hasNotch   ? 2.0
                                    : isMini ? 10
                                    : isMedium ? 15
                                    : 15
            let horizontalSpacing: CGFloat = !hasNotch || isMini ? 30 : isMedium ? 40 : 50
            let titleFont: Font = !hasNotch || isMini ? .title3 : isMedium ? .title2 : .title
            let artwortSize: CGFloat = !hasNotch || isMini ? 250 : isMedium ? 280 : 300
            let iTunesFontSize: CGFloat = !hasNotch || isMini ? 11 : isMedium ? 12 : 13
            let actionButtonSize: CGFloat = !hasNotch || isMini ? 20 : isMedium ? 25 : 30
            let playButtonSize = actionButtonSize + 10
            let mediumFont: Font = !hasNotch || isMini ? .body : isMedium ? .title3 : .title2
            
            VStack(spacing: verticalSpacing) {
                // MARK: – Dismiss‑Button + Play‑Indicator (Overlay)
                
                HStack {
                    // Nur im Sheet‑Modus zeigen wir den Chevron‑Button
                    if isSheet {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.down.circle")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    Spacer()  // schiebt alles nach links

                }
                .padding(20)  // gilt für Button‑HStack
                .overlay(alignment: .trailing) {
                    // immer sichtbare Play‑Indicator‑Logik
                    Group {
                        if manager.isPlaying {
                            NowPlayingBarView()
                        } else {
                            Image(systemName: "waveform")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 20, height: 20)
                    .padding(.horizontal, horizontalPadding)
                }

                // MARK: – MarqueeText
                MarqueeText(
                    text: station.decodedName,
                    font: titleFont,
                    speed: 40
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 10)

                // MARK: – AlbumArtwork + Buffer + iTunes‑Button
                ZStack(alignment: .bottomTrailing) {
                    AlbumArtworkView(
                        artworkURL: manager.currentArtworkURL,
                        frameWidth: artwortSize,
                        frameHeight: artwortSize
                    )
                    if manager.isBuffering {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                            .frame(
                                width: artwortSize,
                                height: artwortSize
                            )
                    }
                    if let trackUrl = manager.currentTrackURL {
                      ITunesLinkButton(trackUrl: trackUrl, fontSize: iTunesFontSize)
                        .padding(.top, 8)
                        .offset(x: 15, y: 15)
                    }
                }
                .padding(.bottom, 10)

                // MARK: – Volume Slider
                VolumeSliderView()

                // MARK: – Track & Artist
                VStack(spacing: 2) {
                    Text(manager.currentTrack.fixEncoding())
                    Text(manager.currentArtist.fixEncoding())
                }
                .font(mediumFont)
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)

                // MARK: – Playback Controls
                HStack(spacing: horizontalSpacing) {
                    ActionButton(systemName: "backward.fill",
                                 buttonSize: actionButtonSize) {
                        manager.setPrevious()
                    }

                    Button {
                        if manager.isPlaying && manager.currentStation == station {
                            manager.pausePlayback()
                        } else {
                            manager.set(station: station)
                        }
                    } label: {
                        Image(systemName:
                            manager.isPlaying && manager.currentStation == station
                            ? "pause.circle.fill"
                            : "play.circle.fill"
                        )
                        .resizable()
                        .frame(
                            width: playButtonSize,
                            height: playButtonSize
                        )
                        .foregroundColor(
                            manager.isPlaying &&
                            manager.currentStation?.id == station.id
                            ? Color("goldorange") : .gray
                        )
                        .shadow(radius: 4)
                    }

                    ActionButton(systemName: "forward.fill",
                                 buttonSize: actionButtonSize) {
                        manager.setNext()
                    }
                }
                .padding(.vertical, bottomPadding)

                // MARK: – SleepTimer + LikeButton
                HStack {
                    SleepTimerView(iconSize: actionButtonSize)
                    if manager.isSleepTimerActive,
                       let remaining = manager.sleepTimerRemainingTime {
                        Text(remaining.asMMSS)
                            .font(isCompact ? .caption : .subheadline)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    LikeButton(station: station,
                               buttonSize: actionButtonSize)
                }
                .padding(.horizontal, horizontalPadding)

                Spacer() // drückt den Stack nach oben
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .frame(maxHeight: .infinity, alignment: .top)
            .applyBackgroundGradient()
            .preferredColorScheme(.dark)
            .onAppear {
                manager.isInPlayerView = true
                manager.prepareForPlayback(
                    station: station,
                    in: filteredStations
                )
            }
            .onDisappear {
                manager.isInPlayerView = false
            }
            .onChange(of: manager.currentStation) { newStation in
                if let newStation = newStation,
                   station.id != newStation.id {
                    station = newStation
                }
            }
        }
    }
}

