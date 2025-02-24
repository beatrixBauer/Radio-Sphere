//
//  StationsManager.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.02.25.
//

import SwiftUI
import FRadioPlayer
import MediaPlayer

class StationsManager: ObservableObject, FRadioPlayerDelegate {
    
    static let shared = StationsManager()
    
    @Published var stations: [RadioStation] = []
    @Published var currentStation: RadioStation?
    @Published var searchedStations: [RadioStation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var currentTrack: String = ""
    @Published var currentArtist: String = ""
    @Published var currentArtworkURL: URL?
    
    @Published var searchText: String = "" {
            didSet { searchStations() } // Startet die Suche automatisch beim Tippen
        }
    
    @Published var alphabetical: Bool = false
    @Published var selectedCountry: String = "Alle"
    @Published var isPlaying = false

    private let player = FRadioPlayer.shared
    private var currentOffset = 0
    private var isFetching = false
    
    private init() {
        player.delegate = self
        fetchStations()
    }
    
    /// Lädt die Radiosender
    func fetchStations() {
        isLoading = true
        errorMessage = nil
        
        DataManager.getStations(offset: 0) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let stations):
                    self?.stations = stations
                case .failure(let error):
                    self?.errorMessage = "Fehler: \(error.localizedDescription)"
                }
            }
        }
    }
    
    
    /// Lädt weitere Sender
    func loadMoreStations() {
        fetchStations()
    }
    
    /// sucht nach Stationen mit Suchtext
    func searchStations() {
           guard !searchText.isEmpty else {
               searchedStations = []
               return
           }

           isLoading = true
           errorMessage = nil

           DataManager.searchStations(query: searchText) { [weak self] result in
               DispatchQueue.main.async {
                   guard let self = self else { return }
                   self.isLoading = false
                   
                   switch result {
                   case .success(let stations):
                       self.searchedStations = stations
                   case .failure(let error):
                       self.errorMessage = "Fehler: \(error.localizedDescription)"
                   }
               }
           }
       }
    
    ///Filter- / Sortierfunktion
    func filteredStations() -> [RadioStation]{
        var results = searchText.isEmpty ? stations : searchedStations
        
        /// nach Land filtern
        if selectedCountry != "Alle"{
            results = results.filter { $0.country == selectedCountry }
        }
        
        ///alphabetisch
        if alphabetical {
            results.sort { $0.name < $1.name }
        }
        return results
    }

    
    /// Setzt den aktuellen Sender
    func set(station: RadioStation) {
        if currentStation == station {
            player.play()
            return
        }

        currentStation = station
        resetMetadata()
        player.radioURL = URL(string: station.url)
        player.play()
    }
    
    /// Nächsten Sender abspielen
    func setNext() {
        guard let index = getIndex(of: currentStation) else { return }
        let nextIndex = (index + 1) % stations.count
        set(station: stations[nextIndex])
    }
    
    /// Vorherigen Sender abspielen
    func setPrevious() {
        guard let index = getIndex(of: currentStation) else { return }
        let prevIndex = (index == 0) ? stations.count - 1 : index - 1
        set(station: stations[prevIndex])
    }
    
    /// Stoppt die Wiedergabe
    func stopPlayback() {
        player.stop()
        resetMetadata()
    }
    
    /// Pausiert die Wiedergabe
    func pausePlayback() {
        player.pause()
    }
    
    /// Setzt Metadaten zurück, wenn kein Song läuft
    private func resetMetadata() {
        currentTrack = ""
        currentArtist = ""
        currentArtworkURL = nil
        updateLockScreen()
    }
    
    /// Gibt den Index eines Senders in der Liste zurück
    private func getIndex(of station: RadioStation?) -> Int? {
        guard let station = station else { return nil }
        return stations.firstIndex(of: station)
    }
    
    /// Wird aufgerufen, wenn Metadaten sich ändern (Songtitel & Künstler)
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        DispatchQueue.main.async {
            // Ungültige Werte, die manche Radiosender während der Werbung senden
            let invalidValues: Set<String> = ["true", "false", "unknown", "advertisement", "ads", "ad break"]

            let cleanedArtist = artistName?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
            let cleanedTrack = trackName?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""

            // Setze Künstler und Track nur, wenn sie nicht in der Liste der ungültigen Werte sind
            if !invalidValues.contains(cleanedArtist) {
                self.currentArtist = artistName?.fixEncoding() ?? ""
            } else {
                self.currentArtist = "Werbung"
            }

            if !invalidValues.contains(cleanedTrack) {
                self.currentTrack = trackName?.fixEncoding() ?? ""
            } else {
                self.currentTrack = "Läuft gerade..."
            }

            print("Neuer Song erkannt: \(self.currentArtist) - \(self.currentTrack)")
            
            guard !self.currentArtist.isEmpty && !self.currentTrack.isEmpty else {
                print("Keine gültigen Metadaten vorhanden")
                return
            }

            // Albumcover nur über iTunes API abrufen
            self.fetchAlbumArtwork()
        }
    }

    /// Holt das Albumcover von iTunes oder Musicbrainz
    private func fetchAlbumArtwork() {
        print("Suche nach Albumcover für \(self.currentArtist) - \(self.currentTrack) (iTunes zuerst, dann MusicBrainz)")
        
        iTunesAPI.shared.getAlbumCover(artist: self.currentArtist, track: self.currentTrack) { url in
            DispatchQueue.main.async {
                if let url = url {
                    print("iTunes Cover gefunden: \(url)")
                    self.currentArtworkURL = url
                    self.updateLockScreen()
                } else {
                    print("Kein Cover von iTunes gefunden, versuche MusicBrainz...")
                    
                    MusicBrainzAPI.shared.getAlbumCover(artistName: self.currentArtist, trackTitle: self.currentTrack) { url in
                        DispatchQueue.main.async {
                            if let url = url {
                                print("MusicBrainz Cover gefunden: \(url)")
                                self.currentArtworkURL = url
                                self.updateLockScreen()
                            } else {
                                print("Kein Albumcover verfügbar.")
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Aktualisiert Metadaten auf dem Sperrbildschirm
    private func updateLockScreen() {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: currentTrack,
            MPMediaItemPropertyArtist: currentArtist
        ]
        
        if let artworkURL = currentArtworkURL {
            DispatchQueue.global(qos: .background).async {
                if let data = try? Data(contentsOf: artworkURL),
                   let image = UIImage(data: data) {
                    
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    
                    DispatchQueue.main.async {
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                    }
                }
            }
        } else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }


    /// Fehlende `FRadioPlayerDelegate`-Methoden hinzugefügt, um Fehler zu vermeiden
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        print("Player State geändert: \(state)")
    }

    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        print("Playback State geändert: \(state)")
        DispatchQueue.main.async {
            self.isPlaying = (state == .playing)
        }
    }

    func radioPlayer(_ player: FRadioPlayer, artworkDidChange artworkURL: URL?) {
        DispatchQueue.main.async {
            guard let newArtworkURL = artworkURL else {
                self.currentArtworkURL = nil
                return
            }
            
            // Falls bereits ein 1200x1200 Cover vorhanden ist, ignorieren wir 100x100
            if let currentURL = self.currentArtworkURL, currentURL.absoluteString.contains("1200x1200") {
                return
            }
            
            // Falls das neue Cover nur 100x100 ist, prüfen, ob wir bereits ein besseres haben
            if newArtworkURL.absoluteString.contains("100x100") {
               
                if self.currentArtworkURL == nil {
                    self.currentArtworkURL = newArtworkURL
                } else {
                }
                return
            }

            print("Neues Artwork erhalten: \(newArtworkURL)")
            self.currentArtworkURL = newArtworkURL
        }
    }

}

