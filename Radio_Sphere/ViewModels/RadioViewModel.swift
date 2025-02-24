//
//  RadioViewModel.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.02.25.
//

import SwiftUI
import FRadioPlayer

class RadioViewModel: ObservableObject, FRadioPlayerDelegate {
    @Published var stations: [RadioStation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Speichert aktuell abgespielten Song & Künstler
    @Published var currentTrack: String = "Unbekannter Titel"
    @Published var currentArtist: String = "Unbekannter Künstler"

    private let player = FRadioPlayer.shared
    
    init() {
        player.delegate = self
    }
    
    // Lädt die Liste der Radiosender
    func loadStations(offset: Int = 0) {
        print("loadStations wurde aufgerufen")
        isLoading = true
        errorMessage = nil
        
        DataManager.getStations(offset: offset) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let stations):
                    self?.stations = stations
                    print("Erfolgreich \(stations.count) Sender geladen!")
                case .failure(let error):
                    self?.errorMessage = "Fehler: \(error.localizedDescription)"
                    print("Fehler beim Laden der Sender: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Suchfunktion für Sender
    func searchStations(query: String) {
        isLoading = true
        errorMessage = nil
        
        DataManager.searchStations(query: query) { [weak self] result in
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
    
    // Startet das Abspielen eines Radiosenders
    func playStation(_ station: RadioStation) {
        guard let streamURL = URL(string: station.url) else { return }
        player.radioURL = streamURL
        player.play()
    }
    
    // Pausiert die Wiedergabe
    func pauseStation() {
        player.pause()
    }
    
    // Stoppt die Wiedergabe
    func stopStation() {
        player.stop()
        DispatchQueue.main.async {
            self.currentTrack = "Unbekannter Titel"
            self.currentArtist = "Unbekannter Künstler"
        }
    }
    
    // Wird aufgerufen, wenn Metadaten sich ändern
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        DispatchQueue.main.async {
            self.currentTrack = trackName ?? "Unbekannter Titel"
            self.currentArtist = artistName ?? "Unbekannter Künstler"
        }
    }
    
    // Notwendige Methoden für FRadioPlayerDelegate hinzugefügt:
    
    /// Wird aufgerufen, wenn der Player-Status sich ändert (z. B. "Loading", "Playing", "Stopped").
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        print("Player State geändert: \(state)")
    }

    /// Wird aufgerufen, wenn der Abspielstatus sich ändert (z. B. "Paused", "Playing").
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        print("Playback State geändert: \(state)")
    }
}

