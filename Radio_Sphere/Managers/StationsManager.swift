//
//  StationsManager.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 02.04.25.
//

import SwiftUI
import FRadioPlayer
import MediaPlayer
import Combine

class StationsManager: ObservableObject, FRadioPlayerDelegate {
    
    static let shared = StationsManager()
    private let locationManager = LocationManager.shared
    var radioAPI = RadioAPI()
    @Published var isInitialized: Bool = false
    
    @Published var allStations: [RadioStation] = [] {
        didSet {
            // Alle Kategorien, werden aktualisiert
            for category in RadioCategory.allCases {
                // Prüfe, ob die Liste für diese Kategorie bereits existiert
                if self.stationsByCategory[category] != nil {
                    self.filteredStationsByCategory[category] = applyFilters(to: category)
                }
            }
        }
    }

    @Published var stations: [RadioStation] = []
    @Published var stationsByCategory: [RadioCategory: [RadioStation]] = [:] // Dictionary mit verschiedenen Listen nach Kategorie
    @Published var filteredStationsByCategory: [RadioCategory: [RadioStation]] = [:] // Dictionary mit gefilterten Listen nach Kategorie
    
    // Navigationsliste für den Player
    @Published var currentNavigationList: [RadioStation] = []
    @Published var userDidPause: Bool = false
    
    // Navigationsliste für das Suchergebnis der direkten API-Suche (SearchView)
    @Published var currentSearchResults: [RadioStation] = []
    
    @Published var currentStation: RadioStation?
    @Published var currentIndex: Int? = nil
    
    @Published var searchedStations: [RadioStation] = []
    @Published var errorMessage: String?
    @Published var isInPlayerView: Bool = false
    @Published var filtersWereReset: Bool = false
    @Published var isSleepTimerActive: Bool = false

    @Published var currentTrack: String = ""
    @Published var currentArtist: String = ""
    @Published var currentArtworkURL: URL?
    @Published var currentTrackURL: URL?
    
    @Published var searchText: String = ""
    @Published var globalSearchText: String = ""
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
    
    // MARK: - Lokale Filterfunktionen für Senderliste
    
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
    
    /// setzt die Filter zurück, aber nur einmal pro Zyklus
    func resetFilters() {
        guard !filtersWereReset else { return }

        searchText = ""
        selectedCountry = "Alle"
        alphabetical = false
        filtersWereReset = true

        print("Filterkriterien wurden EINMALIG zurückgesetzt.")
    }

    /// Setzt manuell das Reset-Flag zurück, z. B. bei Kategorie-Wechsel
    func allowFilterReset() {
        filtersWereReset = false
    }

    // MARK: Startet die API-Abfrage nach Kategoie und händelt den lokale Filterung
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
    
    /// filtert doppelte Stationen raus
    func filterUniqueStationsAndSortByCountry(for category: RadioCategory) {
        // 1. Filtere alle Sender anhand der Kategorie
        let filteredStations = filterStations(for: category)
        
        // 2. Entferne Duplikate basierend auf decodedName
        var uniqueStations = filterUniqueStationsByName(filteredStations)
        
        // 3. Bestimme den bevorzugten Countrycode
        let preferredCountryCode: String = {
            if let currentCode = LocationManager.shared.countryCode {
                return currentCode.uppercased()
            } else if let regionCode = Locale.current.region?.identifier {
                return regionCode.uppercased()
            } else {
                return "DE" // Fallback
            }
        }()
        
        // 4. Sortiere so, dass Sender mit dem bevorzugten Countrycode ganz oben stehen,
        //    danach werden die restlichen alphabetisch (z. B. nach Countrycode) sortiert.
        uniqueStations.sort { (a, b) -> Bool in
            let codeA = a.countrycode.uppercased()
            let codeB = b.countrycode.uppercased()
            if codeA == preferredCountryCode && codeB != preferredCountryCode {
                return true
            } else if codeA != preferredCountryCode && codeB == preferredCountryCode {
                return false
            } else {
                return codeA < codeB
            }
        }
        
        // 5. Speichere das Ergebnis
        self.stationsByCategory[category] = uniqueStations
        print("Kategorie \(category.rawValue) hat \(uniqueStations.count) eindeutige Sender geladen (sortiert nach Countrycode, \(preferredCountryCode) zuerst).")
    }

    
    /// filtert allStations nach der Kategory
    func filterStations(for category: RadioCategory) -> [RadioStation] {
        print("Anzahl in allStations: \(allStations.count)")
        
        // Standardfilterung anhand der Tags
        let searchTags = category.tags.map { $0.lowercased() }
        let tagResults = allStations.filter { station in
            // Falls ein Sender kein tags-Feld hat, fällt er aus
            guard let stationTagsString = station.tags?.lowercased() else {
                return false
            }
            // Teile den tags-String in einzelne Tags (angenommen, sie sind durch Kommas getrennt)
            let stationTags = stationTagsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            // Überprüfe, ob mindestens ein Suchtag in den Stationstags enthalten ist
            return searchTags.contains { searchTag in
                stationTags.contains(searchTag)
            }
        }
        
        // Für bestimmte Kategorien sollen zusätzlich Ergebnisse basierend auf dem Namen berücksichtigt werden.
        var nameResults: [RadioStation] = []
        switch category {
        case .news:
            // Für Nachrichten: Sender, die im Namen "info" enthalten
            nameResults = allStations.filter { station in
                station.decodedName.lowercased().contains("info")
            }
        case .artistRadio:
            // Für ArtistRadio: Sender, die im Namen "exclusive" enthalten
            nameResults = allStations.filter { station in
                station.decodedName.lowercased().contains("exclusive")
            }
        case .party:
            // Für Party: Sender, die im Namen "festival" oder "party" enthalten
            nameResults = allStations.filter { station in
                let lowerName = station.decodedName.lowercased()
                return lowerName.contains("festival")
            }
        default:
            // Für alle anderen Kategorien keine zusätzliche Namenssuche
            break
        }
        
        // Ergebnisse kombinieren und Duplikate entfernen
        var combinedResults = tagResults
        if !nameResults.isEmpty {
            combinedResults.append(contentsOf: nameResults)
            var seenIDs = Set<String>()
            combinedResults = combinedResults.filter { station in
                let lowercasedID = station.id.lowercased()
                if seenIDs.contains(lowercasedID) {
                    return false
                } else {
                    seenIDs.insert(lowercasedID)
                    return true
                }
            }
        }
        
        return combinedResults
    }
    
    
    /// Ruft alle Stationen über den DataManager ab und speichert sie in allStations.
    func loadStations(completion: @escaping () -> Void) {
        DataManager.shared.getAllStations { [weak self] stations in
            DispatchQueue.main.async {
                self?.allStations = stations
                print("Stations geladen: \(stations.count) Sender")
                completion()
            }
        }
    }
    
    // updated filteredStations, welche an die PlayerView übergeben wird
    private func updateFilteredStations(for category: RadioCategory) {
        let filtered = applyFilters(to: category)
        DispatchQueue.main.async {
            self.filteredStationsByCategory[category] = filtered
            print("`filteredStations` für \(category.rawValue) aktualisiert: \(filtered.count) Sender")
        }
    }
    
    
    /// Gibt die Sender für eine bestimmte Kategorie zurück (leeres Array, falls nicht geladen)
    func getStations(for category: RadioCategory) -> [RadioStation] {
        return stationsByCategory[category] ?? []
    }
    
    // MARK: Lokale Suche in allStations (Name und Genre)
    func performGlobalSearch(completion: @escaping () -> Void) {
        guard !globalSearchText.isEmpty else {
            searchedStations = []
            currentSearchResults = []
            completion()
            return
        }
        
        let queryLower = globalSearchText.lowercased()
        
        // Suche nach Sendernamen und Tags (Genre)
        let results = allStations.filter { station in
            // Hier gehen wir davon aus, dass station.decodedName und station.decodedTags
            // die gewünschten Informationen enthalten.
            return station.decodedName.lowercased().contains(queryLower) ||
                   (station.decodedTags?.lowercased().contains(queryLower) ?? false)
        }
        
        let uniqueStations = filterUniqueStationsByName(results)
        
        DispatchQueue.main.async {
            self.searchedStations = uniqueStations
            self.currentSearchResults = uniqueStations
            completion()
        }
    }

    
    /// Fragt die favorisierten Stationen ab und aktualisiert sowohl das Kategorie-Dictionary als auch die gefilterte Stations-Liste.
    func filterByFavoriteStations() {
        let favoriteIDs = FavoritesManager.shared.favoriteStationIDs
        filterStations(withIDs: favoriteIDs, for: .favorites)
    }

    /// Fragt die zuletzt gehörten Stationen ab und aktualisiert sowohl das Kategorie-Dictionary als auch die gefilterte Stations-Liste.
    func filterByRecentStations() {
        let recentIDs = RecentsManager.shared.recentStationIDs
        filterStations(withIDs: recentIDs, for: .recent)
    }

    /// Hilfefunktion Filtern nach id
    private func filterStations(withIDs ids: [String], for category: RadioCategory) {
        guard !ids.isEmpty else {
            print("Keine Sender für Kategorie \(category.rawValue) vorhanden.")
            self.stationsByCategory[category] = []
            self.filteredStationsByCategory[category] = []
            return
        }
        
        // Filtere die Sender, deren ID in der übergebenen Liste enthalten ist (case-insensitive)
        let filteredStations = allStations.filter { station in
            ids.contains { id in
                station.id.lowercased() == id.lowercased()
            }
        }
        
        // Sortiere die gefilterten Sender entsprechend der Reihenfolge der IDs
        let sortedStations = ids.compactMap { id in
            filteredStations.first(where: { $0.id.lowercased() == id.lowercased() })
        }
        
        DispatchQueue.main.async {
            self.stationsByCategory[category] = sortedStations
            self.filteredStationsByCategory[category] = sortedStations
            print("\(category.rawValue.capitalized) geladen: \(sortedStations.count) Sender")
        }
    }



    /// Filtert Sender mit doppelten Namen heraus (basierend auf decodedName)
    func filterUniqueStationsByName(_ stations: [RadioStation]) -> [RadioStation] {
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

        // Hole Standortinformationen, mit Fallbacks, falls nichts vorhanden ist
        _ = locationManager.countryCode ?? Locale.current.region?.identifier ?? "DE"
        let state = locationManager.state ?? ""
        //let lat = locationManager.currentLocation?.coordinate.latitude ?? 0.0
        //let lon = locationManager.currentLocation?.coordinate.longitude ?? 0.0

        // Nutze die globalen Sender aus allStations
        let allStationsGlobal = self.allStations

        // 1. Filtere Sender, die innerhalb eines Radius (hier 50 km) liegen
        let stationsByProximity = locationManager.filterStationsByProximity(allStationsGlobal, maxDistance: 50000.0)
        print("Sender im Umkreis von 50 km: \(stationsByProximity.count)")

        // 2. Filtere zusätzlich nach Bundesland, falls vorhanden
        let stationsByState: [RadioStation] = state.isEmpty ? [] : allStationsGlobal.filter { station in
            guard let stationState = station.state?.lowercased() else { return false }
            return stationState == state.lowercased()
        }
        print("Sender basierend auf dem Bundesland: \(stationsByState.count)")

        // 3. Kombiniere beide Filter-Ergebnisse und entferne Duplikate
        let combinedStations = stationsByProximity + stationsByState
        let uniqueStations = Array(Dictionary(combinedStations.map { ($0.id, $0) },
                                              uniquingKeysWith: { first, _ in first }).values)

        // 4. Falls nach diesen Filtern keine Sender gefunden werden, verwende als Fallback alle deutschen Sender aus allStations
        let finalStations: [RadioStation]
        if uniqueStations.isEmpty {
            finalStations = allStationsGlobal.filter { station in
                station.country.lowercased() == "de"
            }
            print("Fallback aktiviert – keine lokalen Sender gefunden, gefiltert: \(finalStations.count) deutsche Sender")
        } else {
            finalStations = uniqueStations
        }

        // 5. Sortiere die finalen Sender basierend auf der Entfernung zum aktuellen Standort
        let sortedStations = finalStations.sorted { first, second in
            let firstDistance = locationManager.getDistanceToStation(station: first) ?? Double.infinity
            let secondDistance = locationManager.getDistanceToStation(station: second) ?? Double.infinity
            return firstDistance < secondDistance
        }

        DispatchQueue.main.async {
            self.stationsByCategory[.local] = sortedStations
            print("Kombinierte lokale Sender geladen: \(sortedStations.count) Sender")
        }
    }
    
    
    /// Ermittelt aus einer angezeigten Liste mit Radiostationen die verschiedenen Länder für die Filterung nach Land
    func getAvailableCountries(for category: RadioCategory) -> [String] {
        let stations = getStations(for: category)
        let countries = stations.map { $0.decodedCountry }
        return Array(Set(countries)).sorted()
    }
    
    /// Überprüft, ob die Sender für eine Kategorie bereits geladen wurden
    func isCategoryLoaded(_ category: RadioCategory) -> Bool {
        return stationsByCategory[category] != nil
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

    
    // MARK: Funktionen zur Playerbedienung über das Commandcenter
    
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
    
    
    // MARK: - Übermittlung der Radiostationen an den Player
    
    /// Setzt den ausgewählten Sender
    func set(station: RadioStation) {
        // Wenn derselbe Sender erneut gewählt wird, setze den Pause-Flag zurück und starte den Sender.
        if currentStation == station {
            userDidPause = false
            player.play()
            return
        }
        
        // Beim Wechsel eines Senders wird der Pause-Flag zurückgesetzt.
        userDidPause = false
        currentStation = station
        resetMetadata()
        player.radioURL = URL(string: station.url)
        player.play()
        
        print("Rohname: \(station.name)")
        print("Dekodierter Name: \(station.decodedName)")
    }


    
    /// Legt die aktuelle Navigationliste fest und bereitet den Player vor.
    func prepareForPlayback(station: RadioStation, in list: [RadioStation]) {
        // Nur aktualisieren, wenn ein neuer Sender ausgewählt wurde
        if currentStation?.id != station.id {
            set(station: station)
            // Speichere den Snapshot für die Navigation nur beim Wechsel des Senders
            currentNavigationList = list
            currentIndex = list.firstIndex { $0.id == station.id }
            print("PlayerView: currentIndex gesetzt auf \(currentIndex ?? -1)")
        }
        
        RecentsManager.shared.addRecentStation(station.id)
    }
    
    /// Schaltet auf die vorherige Station in der aktuellen Navigationsliste um
    func setPrevious() {
        guard let index = currentIndex, index > 0,
              currentNavigationList.indices.contains(index - 1) else {
            print("Kein vorheriger Sender verfügbar.")
            return
        }
        
        let prevStation = currentNavigationList[index - 1]
        currentIndex = index - 1
        set(station: prevStation)
        print("Wechsle zu: \(prevStation.decodedName) (Index: \(currentIndex!))")
    }
    
    /// Schaltet auf die nächste Station in der aktuellen Navigationsliste um
    func setNext() {
        guard let index = currentIndex,
              index < currentNavigationList.count - 1 else {
            print("Kein nächster Sender verfügbar.")
            return
        }
        
        let nextStation = currentNavigationList[index + 1]
        currentIndex = index + 1
        set(station: nextStation)
        print("Wechsle zu: \(nextStation.decodedName) (Index: \(currentIndex!))")
    }
    
    // MARK: - Playerbedienung
    /// Stoppt die Wiedergabe
    func stopPlayback() {
        player.stop()
        resetMetadata()
    }
    
    /// Pausiert die Wiedergabe
    func pausePlayback() {
        userDidPause = true
        player.pause()
    }
    
    // MARK: - Metadatenverwaltung
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
    
    
    // MARK: - Wird aufgerufen, wenn Metadaten sich ändern (Songtitel & Künstler)
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        DispatchQueue.main.async {
            // Ungültige Werte, die manche Radiosender während Werbung oder Pausen senden
            let invalidValues: Set<String> = ["true", "false", "unknown", "advertisement", "ads", "ad break"]

            // Gibberish-Muster, z. B. wenn der Text keine Leerzeichen enthält und länger als 20 Zeichen ist
            func isLikelyGibberish(_ text: String) -> Bool {
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                // Wenn es keine Leerzeichen enthält und länger als 10 Zeichen ist, könnte es sich um einen Code handeln.
                return !trimmed.contains(" ") && trimmed.count > 20
            }
            
            // Bereinige Artist und Track (nur zum Vergleichen)
            let cleanedArtist = artistName?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
            let cleanedTrack = trackName?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
            
            // Standardwerte für Artist und Track setzen:
            var displayArtist = self.currentStation?.name ?? "Unbekannter Sender"
            var displayTrack = "On Air"
            
            // Wenn der empfangene Artist-String mit "{" beginnt, verwenden wir den Fallback
            if let trimmedArtist = artistName?.trimmingCharacters(in: .whitespacesAndNewlines), trimmedArtist.first == "{" {
                displayArtist = self.currentStation?.name ?? "Unbekannter Sender"
            } else if !invalidValues.contains(cleanedArtist), let artist = artistName, !artist.isEmpty {
                displayArtist = artist.fixEncoding()
            }
            
            // Gleiches gilt für den Track: Wenn er mit "{" beginnt, Fallback verwenden
            if let trimmedTrack = trackName?.trimmingCharacters(in: .whitespacesAndNewlines), trimmedTrack.first == "{" {
                displayTrack = "On Air"
            } else if !invalidValues.contains(cleanedTrack), let track = trackName, !track.isEmpty {
                // Zudem prüfen, ob der Track-Name wie ein Code aussieht
                if !isLikelyGibberish(track) {
                    displayTrack = track.fixEncoding()
                }
            }
            
            self.currentArtist = displayArtist
            self.currentTrack = displayTrack
            
            print("Jetzt läuft: \(self.currentArtist) - \(self.currentTrack)")
            
            // Albumcover abrufen (auch wenn "On Air", um das Sender-Logo zu laden, falls verfügbar)
            self.fetchAlbumArtwork()
        }
    }


    // MARK: Holt das Albumcover von iTunes oder Musicbrainz
    // verwendet updateLockScreen()
    private func fetchAlbumArtwork() {
        print("Suche nach Albumcover für \(self.currentArtist) - \(self.currentTrack) (iTunes zuerst, dann MusicBrainz)")
        
        iTunesAPI.shared.getAlbumCover(artist: self.currentArtist, track: self.currentTrack) { coverUrl, trackUrl in
            DispatchQueue.main.async {
                if let coverUrl = coverUrl {
                    print("iTunes Cover gefunden: \(coverUrl)")
                    self.currentArtworkURL = coverUrl
                    // Setze die TrackURL nur, wenn sie vorhanden ist.
                    self.currentTrackURL = trackUrl
                    if let trackUrl = trackUrl {
                        print("iTunes Track URL gefunden: \(trackUrl)")
                    }
                    self.updateLockScreen()
                } else {
                    print("Kein Cover von iTunes gefunden, versuche MusicBrainz...")
                    
                    // Wenn MusicBrainz genutzt wird, könntest du currentTrackURL auch auf nil setzen,
                    // falls es dort keinen Link gibt.
                    MusicBrainzAPI.shared.getAlbumCover(artistName: self.currentArtist, trackTitle: self.currentTrack) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let url):
                                print("MusicBrainz Cover gefunden: \(url)")
                                self.currentArtworkURL = url
                                // Hier: Da von MusicBrainz normalerweise kein Track-Link geliefert wird,
                                // setzen wir currentTrackURL auf nil:
                                self.currentTrackURL = nil
                                self.updateLockScreen()
                            case .failure(let error):
                                print("Kein Albumcover verfügbar: \(error)")
                                self.currentTrackURL = nil  // Sicherstellen, dass hier nil gesetzt wird.
                            }
                        }
                    }
                }
            }
        }
    }

    
    // MARK: Aktualisiert Metadaten auf dem Sperrbildschirm
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


    // MARK: reagiert auf Änderungen im allgemeinen Player-Zustand und gibt lediglich den neuen Zustand per Print aus
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        print("Player State geändert: \(state)")
    }

    // MARK: reagiert speziell auf Änderungen im Wiedergabezustand und aktualisiert zusätzlich die Eigenschaft isPlaying im Main-Thread, sodass die UI entsprechend reagiert.
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        print("Playback State geändert: \(state)")
        DispatchQueue.main.async {
            self.isPlaying = (state == .playing)
        }
    }

    // MARK: reagiert auf Änderungen in den Metadaten bezüglich des Albumcovers und gibt den neuen Zustand weiter, damit das neue Cover abgefragt werden kann.
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


//MARK: alte Funktionen zur Api-Abfrage
/*
 
 /// Lädt die Sender basierend auf einer Kategorie, filtert Duplikate und sortiert nach Land (Deutschland zuerst)
 func fetchStationsByTag(for category: RadioCategory) {
    DataManager.shared.getStationsByTag(for: category) { [weak self] stations in
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
 
 /// fragt zuletzt gehörte Stationen ab
func fetchRecentStations() {
     let recentIDs = RecentsManager.shared.recentStationIDs

     guard !recentIDs.isEmpty else {
         print("Keine kürzlich gehörten Sender vorhanden.")
         self.stationsByCategory[.recent] = []
         self.filteredStationsByCategory[.recent] = []
         return
     }
     
     Task { [weak self] in
         guard let self = self else { return }
         let recentStations = await DataManager.shared.fetchStationsByIDs(recentIDs)

         await MainActor.run {
             self.stationsByCategory[.recent] = recentStations
             self.filteredStationsByCategory[.recent] = recentStations
             print("Zuletzt gehörte Sender geladen: \(recentStations.count) Sender")
         }
     }
 }
 
 
 /// Fragt die favorisierten Stationen ab und aktualisiert sowohl das Kategorie-Dictionary als auch die globale filteredStations-Liste.
 func fetchFavoriteStations() {
     let favoriteIDs = FavoritesManager.shared.favoriteStationIDs

     guard !favoriteIDs.isEmpty else {
         print("Keine Favoriten vorhanden.")
         self.stationsByCategory[.favorites] = []
         self.filteredStationsByCategory[.favorites] = []
         return
     }
     
     Task { [weak self] in
         guard let self = self else { return }
         let favoriteStations = await DataManager.shared.fetchStationsByIDs(favoriteIDs)
         await MainActor.run {
             self.stationsByCategory[.favorites] = favoriteStations
             self.filteredStationsByCategory[.favorites] = favoriteStations
             print("Favoriten geladen: \(favoriteStations.count) Sender")
         }
     }
 }
 
 func filterByFavoriteStations() {
     // Hole die zuletzt gehörten Sender-IDs
     let favoriteIDs = FavoritesManager.shared.favoriteStationIDs
     
     guard !favoriteIDs.isEmpty else {
         print("Keine favorisierten Sender vorhanden.")
         self.stationsByCategory[.favorites] = []
         self.filteredStationsByCategory[.favorites] = []
         return
     }
     
     // Zugriff auf die Liste aller Stationen
     let allStations = allStations
    
     // Filtere die Sender, deren ID in recentIDs vorkommt, case-insensitive
     let filteredStations = allStations.filter { station in
         favoriteIDs.contains { favoriteID in
             station.id.lowercased() == favoriteID.lowercased()
         }
     }
     
     // Sortiere die gefilterte Liste so, dass die Reihenfolge der IDs aus recentIDs übernommen wird, auch hier case-insensitive
     let sortedStations = favoriteIDs.compactMap { id in
         filteredStations.first(where: { $0.id.lowercased() == id.lowercased() })
     }
     
     DispatchQueue.main.async {
         self.stationsByCategory[.favorites] = sortedStations
         self.filteredStationsByCategory[.favorites] = sortedStations
         print("Favorisierte Sender geladen: \(sortedStations.count) Sender")
     }
 }

 
 func filterByRecentStations() {
     // Hole die zuletzt gehörten Sender-IDs
     let recentIDs = RecentsManager.shared.recentStationIDs
     
     guard !recentIDs.isEmpty else {
         print("Keine kürzlich gehörten Sender vorhanden.")
         self.stationsByCategory[.recent] = []
         self.filteredStationsByCategory[.recent] = []
         return
     }
     
     // Zugriff auf die Liste aller Stationen
     let allStations = allStations
     
     // Filtere die Sender, deren ID in recentIDs vorkommt, case-insensitive
     let filteredStations = allStations.filter { station in
         recentIDs.contains { recentID in
             station.id.lowercased() == recentID.lowercased()
         }
     }
     
     // Sortiere die gefilterte Liste so, dass die Reihenfolge der IDs aus recentIDs übernommen wird, auch hier case-insensitive
     let sortedStations = recentIDs.compactMap { id in
         filteredStations.first(where: { $0.id.lowercased() == id.lowercased() })
     }
     
     DispatchQueue.main.async {
         self.stationsByCategory[.recent] = sortedStations
         self.filteredStationsByCategory[.recent] = sortedStations
         print("Zuletzt gehörte Sender geladen: \(sortedStations.count) Sender")
     }
 }
 
 
 
 func fetchLocalStations() {
     let locationManager = LocationManager.shared
     
     // Fallback für den Ländercode, falls der Standort nicht verfügbar ist
     let countryCode = locationManager.countryCode ?? Locale.current.region?.identifier ?? "DE"
     let state = locationManager.state ?? ""
     let lat = locationManager.currentLocation?.coordinate.latitude ?? 0.0
     let lon = locationManager.currentLocation?.coordinate.longitude ?? 0.0
     
     DataManager.shared.getCombinedLocalStations(
         countryCode: countryCode,
         state: state,
         lat: lat,
         lon: lon
     ) { [weak self] stations in
         guard let self = self else { return }
         
         var localStations: [RadioStation] = []
         if stations.isEmpty {
             // Fallback: Falls keine Sender zurückgegeben werden, filtere deutsche Sender aus allStations
             localStations = self.allStations.filter { station in
                 station.country.lowercased() == "de"
             }
             print("Fallback aktiviert – keine lokalen Sender gefunden, gefiltert: \(localStations.count) deutsche Sender")
         } else {
             localStations = stations
         }
         
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
 
 // MARK: API-Suchfunktion
 // wird in der SearchView verwendet und sucht direkt in der API nach einem Stationsnamen
 func performGlobalSearch(completion: @escaping () -> Void) {
     guard !globalSearchText.isEmpty else {
         searchedStations = []
         // Aktualisiere den Such-Snapshot (leere Liste)
         currentSearchResults = []
         completion()
         return
     }
     
     DataManager.shared.searchStationsByName(query: globalSearchText) { [weak self] stations in
         DispatchQueue.main.async {
             self?.searchedStations = stations
             // Setze den stabilen Snapshot für die Suchergebnisse
             self?.currentSearchResults = stations
             completion()
         }
     }
 }
 
 */

