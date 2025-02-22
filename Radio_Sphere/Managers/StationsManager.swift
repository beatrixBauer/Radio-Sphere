import SwiftUI
import FRadioPlayer
import MediaPlayer

class StationsManager: ObservableObject, FRadioPlayerDelegate {
    
    static let shared = StationsManager()
    
    @Published var stations: [RadioStation] = []
    @Published var currentStation: RadioStation?
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var currentTrack: String = "Unbekannter Titel"
    @Published var currentArtist: String = "Unbekannter Künstler"
    @Published var currentArtwork: UIImage? = nil

    private let player = FRadioPlayer.shared
    
    private init() {
        player.delegate = self
        fetchStations()
    }
    
    /// Lädt die Radiosender
    func fetchStations() {
        isLoading = true
        errorMessage = nil
        
        DataManager.getStations { [weak self] result in
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
    
    /// Setzt den aktuellen Sender
    func set(station: RadioStation) {
        currentStation = station
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
    
    /// Suchfunktion für Sender
    func searchStations(query: String) {
        DispatchQueue.main.async {
            self.stations = self.stations.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }
    }
    
    /// Setzt Metadaten zurück, wenn kein Song läuft
    private func resetMetadata() {
        currentTrack = "Unbekannter Titel"
        currentArtist = "Unbekannter Künstler"
        currentArtwork = nil
        updateLockScreen()
    }
    
    /// Gibt den Index eines Senders in der Liste zurück
    private func getIndex(of station: RadioStation?) -> Int? {
        guard let station = station else { return nil }
        return stations.firstIndex(of: station)
    }
    
    /// 🎵 Wird aufgerufen, wenn Metadaten sich ändern (Songtitel & Künstler)
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        DispatchQueue.main.async {
            self.currentTrack = trackName ?? "Unbekannter Titel"
            self.currentArtist = artistName ?? "Unbekannter Künstler"
            self.updateLockScreen()
        }
    }
    
    /// 🎨 Aktualisiert das Albumcover
    func radioPlayer(_ player: FRadioPlayer, artworkDidChange artworkURL: URL?) {
        guard let artworkURL = artworkURL else {
            DispatchQueue.main.async {
                self.currentArtwork = nil
                self.updateLockScreen()
            }
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: artworkURL), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.currentArtwork = image
                    self.updateLockScreen()
                }
            }
        }
    }
    
    /// 🎶 Aktualisiert Metadaten auf dem Sperrbildschirm
    private func updateLockScreen() {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: currentTrack,
            MPMediaItemPropertyArtist: currentArtist
        ]
        
        if let artwork = currentArtwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size, requestHandler: { _ in artwork })
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    /// Wird aufgerufen, wenn der Player-Status sich ändert (z. B. "Loading", "Playing", "Stopped").
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        print("Player State geändert: \(state)")
    }

    /// Wird aufgerufen, wenn der Abspielstatus sich ändert (z. B. "Paused", "Playing").
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        print("Playback State geändert: \(state)")
    }
}
