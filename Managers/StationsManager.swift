//
//  StationsManager.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.02.25.
//

import SwiftUI
import FRadioPlayer
import MediaPlayer
import Combine

class StationsManager: ObservableObject, FRadioPlayerDelegate {
    
    static let shared = StationsManager()
    private let locationManager = LocationManager.shared
    private let radioAPI = RadioAPI()
    
    @Published var stations: [RadioStation] = []
    @Published var stationsByCategory: [RadioCategory: [RadioStation]] = [:] // Dictionary mit verschiedenen Listen nach Kategorie
    @Published var currentStation: RadioStation?
    @Published var filteredStations: [RadioStation] = []
    @Published var currentIndex: Int? = nil
    @Published var searchedStations: [RadioStation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var currentTrack: String = ""
    @Published var currentArtist: String = ""
    @Published var currentArtworkURL: URL?
    
    @Published var searchText: String = ""
    @Published var searchActive = false
    private var searchCancellable: AnyCancellable?

    @Published var alphabetical: Bool = false
    @Published var selectedCountry: String = "Alle"
    @Published var isPlaying = false

    private let player = FRadioPlayer.shared
   // private var currentOffset = 0
   // private var isFetching = false
    
    private init() {
        player.delegate = self
        setupSearch()
        setupRemoteCommandCenter()
    }
    
    // MARK: - Zentrale Filterfunktion für Senderliste
    
    /// Initialisiert die Suchlogik mit Debouncing
       private func setupSearch() {
           searchCancellable = $searchText
               .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
               .removeDuplicates()
               .sink { [weak self] text in
                   self?.handleSearchTextChange(text)
               }
       }
       
       /// Aktiviert die Suchfunktion
       func activateSearch() {
           searchActive = true
           print("Suche aktiviert.")
       }
       
       /// Deaktiviert die Suchfunktion
       func deactivateSearch() {
           searchActive = false
           searchedStations = []
           print("Suche deaktiviert und Liste zurückgesetzt.")
       }
    
    /// Handhabt Änderungen im Suchtext
    func handleSearchTextChange(_ text: String) {
        if text.isEmpty && searchActive {
            // Nur deaktivieren, wenn die Suche aktiv ist und wirklich zurückgekehrt wurde
            deactivateSearch()
        } else if !text.isEmpty {
            activateSearch()
            applySearchFilter(with: text)
        } else {
            print("Suchfeld geleert, aber Suche bleibt aktiv.")
        }
    }
    
    /// Wendet die Suchfilter auf die Senderliste an
    private func applySearchFilter(with text: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let lowercasedText = text.lowercased()
            let results = self.stations.filter { station in
                station.decodedName.lowercased().contains(lowercasedText) ||
                (station.decodedTags?.lowercased().contains(lowercasedText) ?? false)
            }
            
            DispatchQueue.main.async {
                self.searchedStations = results
            }
        }
    }
    
    /// setzt die Filter zurück
    func resetFilters() {
        searchText = ""
        selectedCountry = "Alle"
        alphabetical = false
        print("Filterkriterien wurden zurückgesetzt.")
    }

    
    /// Wendet die lokalen Filter auf die Senderliste an
    func applyFilters(to category: RadioCategory) -> [RadioStation] {
        var results = getStations(for: category)
        
        // Filterung nach Suchtext
        if searchActive, !searchText.isEmpty {
            results = results.filter { station in
                station.decodedName.lowercased().contains(searchText.lowercased()) ||
                (station.decodedTags?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        
        // Filterung nach ausgewähltem Land
        if selectedCountry != "Alle" {
            results = results.filter { station in
                station.decodedCountry == selectedCountry
            }
        }
        
        // Sortierung nach Alphabet
        if alphabetical {
            results.sort { $0.decodedName < $1.decodedName }
        }
        
        return results
    }
    
    func updateFilteredStations(for category: RadioCategory) {
        DispatchQueue.main.async {
            self.filteredStations = self.applyFilters(to: category)
            print(" `filteredStations` aktualisiert: \(self.filteredStations.count) Sender")
        }
    }

    
    // MARK: Funktionen zum Laden der Radiosender
    /// Lädt die Radiosender
    func fetchStations() {
        isLoading = true
        errorMessage = nil

        DataManager.getStations() { [weak self] stations in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.stations = stations
            }
        }
    }
    
    /// Gibt die Sender für eine bestimmte Kategorie zurück (leeres Array, falls nicht geladen)
    func getStations(for category: RadioCategory) -> [RadioStation] {
        return stationsByCategory[category] ?? []
    }
    
    /// Lädt die Sender basierend auf einer Kategorie, filtert Duplikate und sortiert nach Land (Deutschland zuerst)
    func fetchStationsByTag(for category: RadioCategory) {
        DataManager.getStationsByTag(for: category) { [weak self] stations in
            DispatchQueue.main.async {
                // Filtert Sender mit doppelten Namen heraus
                var uniqueStations = self?.filterUniqueStationsByName(stations) ?? []
                
                // Sortiert die Sender nach Land: Deutsche Sender zuerst, dann alphabetisch nach Land
                uniqueStations.sort { (a: RadioStation, b: RadioStation) in
                    if a.country.lowercased() == "germany" && b.country.lowercased() != "germany" {
                        return true
                    } else if a.country.lowercased() != "germany" && b.country.lowercased() == "germany" {
                        return false
                    } else {
                        return a.country < b.country
                    }
                }
                
                self?.stationsByCategory[category] = uniqueStations
                print("Kategorie \(category.rawValue) hat \(uniqueStations.count) eindeutige Sender geladen (sortiert nach Land, DE zuerst).")
                
                // Debug-Ausgabe zur Überprüfung der Sortierung
                /*uniqueStations.forEach { station in
                    print("Sender: \(station.decodedName) - Land: \(station.country)")
                }*/
            }
        }
    }

    
    /// Fragt die favorisierten Stationen ab
    func fetchFavoriteStations() {
        let favoriteIDs = FavoritesManager.shared.favoriteStationIDs
        
        guard !favoriteIDs.isEmpty else {
            print("Keine Favoriten vorhanden.")
            self.stationsByCategory[.favorites] = []
            return
        }
        
        DataManager.getStationsByIDs(favoriteIDs) { [weak self] favoriteStations in
            DispatchQueue.main.async {
                self?.stationsByCategory[.favorites] = favoriteStations
                print("Favoriten geladen: \(favoriteStations.count) HTTPS-Sender")
            }
        }
    }
    
    /// Fragt die zuletzt gehörten Sender ab
    func fetchRecentStations() {
        let recentIDs = RecentsManager.shared.recentStationIDs
        
        guard !recentIDs.isEmpty else {
            print("Keine kürzlich gehörten Sender vorhanden.")
            self.stationsByCategory[.recent] = []
            return
        }
        
        DataManager.getStationsByIDs(recentIDs) { [weak self] recentStations in
            DispatchQueue.main.async {
                self?.stationsByCategory[.recent] = recentStations
                print("Zuletzt gehörte Sender geladen: \(recentStations.count) HTTPS-Sender")
            }
        }
    }


    /// Filtert Sender mit doppelten Namen heraus (basierend auf decodedName)
    private func filterUniqueStationsByName(_ stations: [RadioStation]) -> [RadioStation] {
        print("Entferne doppelten Sender...")
        var seenNames = Set<String>()
        return stations.filter { station in
            let name = station.decodedName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            guard !seenNames.contains(name) else {
                return false
            }
            seenNames.insert(name)
            return true
        }
    }
    
    /// Sucht lokale Sender und sortiert sie nach Distanz
    func fetchLocalStations() {
        let locationManager = LocationManager.shared
        
        // Fallback für den Ländercode, falls der Standort nicht verfügbar ist
        let countryCode = locationManager.countryCode ?? Locale.current.region?.identifier ?? "DE"
        let state = locationManager.state ?? ""
        let lat = locationManager.currentLocation?.coordinate.latitude ?? 0.0
        let lon = locationManager.currentLocation?.coordinate.longitude ?? 0.0
        
        DataManager.getCombinedLocalStations(
            countryCode: countryCode,
            state: state,
            lat: lat,
            lon: lon
        ) { [weak self] stations in
            guard let self = self else { return }
            
            // Sortiere die Sender basierend auf der Distanz (Sender ohne Geo-Daten kommen ans Ende)
            let sortedStations = stations.sorted { (first, second) -> Bool in
                let firstDistance = locationManager.getDistanceToStation(station: first) ?? Double.infinity
                let secondDistance = locationManager.getDistanceToStation(station: second) ?? Double.infinity
                return firstDistance < secondDistance
            }

            DispatchQueue.main.async {
                self.stationsByCategory[.local] = sortedStations
                print("Kombinierte lokale Sender geladen: \(sortedStations.count) Sender")
            }
        }
    }
    
    
    /// Holt alle verfügbaren Länder aus der Senderliste (für den Picker)
    func getAvailableCountries(for category: RadioCategory) -> [String] {
        let stations = getStations(for: category)
        let countries = stations.map { $0.decodedCountry }
        return Array(Set(countries)).sorted()
    }
    
    /// Überprüft, ob die Sender für eine Kategorie bereits geladen wurden
    func isCategoryLoaded(_ category: RadioCategory) -> Bool {
        return stationsByCategory[category] != nil
    }
    
    /// Lädt weitere Sender
    func loadMoreStations() {
        fetchStations()
    }
    
    /// Sucht lokal nach Stationen mit Suchtext
    func searchStations() {
        guard !searchText.isEmpty else {
            searchedStations = []
            print("Suchfeld ist leer, Liste zurückgesetzt.")
            return
        }

        print("Starte lokale Suche nach: \(searchText)")
        
        // Lokale Suche durch Filterung der bereits geladenen Stationen
        searchedStations = stations.compactMap { $0 }.filter { station in
            station.decodedName.lowercased().contains(searchText.lowercased()) ||
            (station.decodedTags?.lowercased().contains(searchText.lowercased()) ?? false)
        }
        self.objectWillChange.send()
    }


    ///Filter- / Sortierfunktion
 /*   func filteredStations() -> [RadioStation]{
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
    }*/

    
    // MARK: Funktionen zur Controlle der Abspielfunktion
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        // Play-Button auf dem Sperrbildschirm
        commandCenter.playCommand.addTarget { [unowned self] _ in
            if let currentStation = self.currentStation {
                self.set(station: currentStation)
            }
            return .success
        }

        // Pause-Button auf dem Sperrbildschirm
        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            self.pausePlayback()
            return .success
        }

        // Stop-Button auf dem Sperrbildschirm
        commandCenter.stopCommand.addTarget { [unowned self] _ in
            self.stopPlayback()
            return .success
        }

        // Nächster Sender
        commandCenter.nextTrackCommand.addTarget { [unowned self] _ in
            self.setNext()
            return .success
        }

        // Vorheriger Sender
        commandCenter.previousTrackCommand.addTarget { [unowned self] _ in
            self.setPrevious()
            return .success
        }
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
        
        print("Rohname: \(station.name)")
        print("Dekodierter Name: \(station.decodedName)")
    }
    
    /// Nächsten Sender abspielen
  /*  func setNext() {
        guard let index = getIndex(of: currentStation) else { return }
        let nextIndex = (index + 1) % stations.count
        set(station: stations[nextIndex])
    }
    
    /// Vorherigen Sender abspielen
    func setPrevious() {
        guard let index = getIndex(of: currentStation) else { return }
        let prevIndex = (index == 0) ? stations.count - 1 : index - 1
        set(station: stations[prevIndex])
    }*/
    
    func setNext() {
        guard let index = currentIndex, index < filteredStations.count - 1 else {
            print("Kein nächster Sender verfügbar.")
            return
        }

        let nextStation = filteredStations[index + 1]
        currentIndex = index + 1
        set(station: nextStation)

        print("Wechsle zu: \(nextStation.decodedName) (Index: \(currentIndex!))")
    }

    func setPrevious() {
        guard let index = currentIndex, index > 0 else {
            print("Kein vorheriger Sender verfügbar.")
            return
        }

        let prevStation = filteredStations[index - 1]
        currentIndex = index - 1
        set(station: prevStation)

        print("Wechsle zu: \(prevStation.decodedName) (Index: \(currentIndex!))")
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
            // Ungültige Werte, die manche Radiosender während Werbung oder Pausen senden
            let invalidValues: Set<String> = ["true", "false", "unknown", "advertisement", "ads", "ad break"]

            let cleanedArtist = artistName?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
            let cleanedTrack = trackName?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""

            // Standardwerte für Artist und Track setzen
            var displayArtist = self.currentStation?.name ?? "Unbekannter Sender"
            var displayTrack = "On Air"

            // Falls Artist valide ist, setzen
            if !invalidValues.contains(cleanedArtist), let artist = artistName, !artist.isEmpty {
                displayArtist = artist.fixEncoding()
            }

            // Falls Track valide ist, setzen
            if !invalidValues.contains(cleanedTrack), let track = trackName, !track.isEmpty {
                displayTrack = track.fixEncoding()
            }

            self.currentArtist = displayArtist
            self.currentTrack = displayTrack

            print("Jetzt läuft: \(self.currentArtist) - \(self.currentTrack)")

            // Albumcover abrufen (auch wenn "On Air", um das Sender-Logo zu laden, falls verfügbar)
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

