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

    static let shared = StationsManager()                                               // Singleton StationsManager
    private let locationManager = LocationManager.shared                                // Zugriff auf die Logik im LocationManager
    private let player = FRadioPlayer.shared                                            // Zugriff auf FRadioPlayer-Funktionen
    private var searchCancellable: AnyCancellable?                                      // SuchText-Variable
    private var sleepTimer: Timer?                                                      // Variable für Sleeptimer
    
    //MARK: Published States
    @Published var allStations: [RadioStation] = [] {
        didSet {
            // Alle Kategorien, werden aktualisiert wenn sich der Status von allStations verändert
            for category in RadioCategory.allCases {
                if self.stationsByCategory[category] != nil {
                    self.filteredStationsByCategory[category] = applyFilters(to: category)
                }
            }
        }
    }
    //Stations Listen
    @Published var stationsByCategory: [RadioCategory: [RadioStation]] = [:]            // Basis Dictionary mit Kategorie-Listen aus allStations
    @Published var filteredStationsByCategory: [RadioCategory: [RadioStation]] = [:]    // gefilterte Kategorie-Listen (z.B. durch Suche oder Sortierung)
    
    // Player-relevante Stationen
    @Published var currentNavigationList: [RadioStation] = []                           // Navigations-Stationsliste, die dem Player übergeben wird
    @Published var currentStation: RadioStation?                                        // aktuell ausgewählte Station im Player
    @Published var currentIndex: Int?                                                   // Index der ausgewählten Station in der Navigations-Liste
    
    // Für die Text-Suche in der StationsView
    @Published var searchText: String = ""                                              // Verwendung im Suchfeld der StationsView
    @Published var searchActive = false                                                 // überwacht, ob das Suchfeld aktiviert wurde
    @Published var stations: [RadioStation] = []                                        // Ausgangspunkt für searchedStations in der Suchfunktion
    @Published var searchedStations: [RadioStation] = []                                // Suchergebnis der Text-Suchfunktion
    
    // Für die globale Text-Suche in der SearchView
    @Published var globalSearchText: String = ""
    @Published var currentSearchResults: [RadioStation] = []                            // Ergebnisliste der globalen Textsuche
    
    
    @Published var selectedCountry: String = "Alle"                                     // Für die Filterung nach Land in der StationsView
    @Published var sortMode: SortMode = .grouped                                        // Sortier-Reihenfolge nach Alphabeth mit verschieden Zuständen
    
    // Beobachter
    @Published var isInPlayerView: Bool = false                                         // Beobachtung, ob der Nutzer in der PlayerView ist
    @Published var filtersWereReset: Bool = false                                       // Beobachtung des Filter-Sortier-Status
    @Published var userDidPause: Bool = false                                           // Bobachtung, ob der User den Player pausiert hat
    @Published var isPlaying = false                                                    // Beobachtung, ob der Player spielt
    @Published var isBuffering = false                                                  // Beobachtung, ob noch gepuffert wird
    @Published var isSleepTimerActive: Bool = false                                     // Beobachtung des SleepTimers
    
    // Sleeptimer verbleibende Zeit
    @Published var sleepTimerRemainingTime: Int? = nil

    // Metadaten
    @Published var currentTrack: String = ""                                            // aktueller Song
    @Published var currentArtist: String = ""                                           // aktueller Künstler
    @Published var currentArtworkURL: URL?                                              // aktuelles Albumcover
    @Published var currentTrackURL: URL?                                                // Url des ausgewählten Senders
    
    // Init
    private init() {
        player.delegate = self                                                          // Initiierung von FRadioPlayer
        setupSearch()                                                                   // Initiierung des Suchfeldes in der StationsView
        setupRemoteCommandCenter()                                                      // Initiierung der Playerbedienung im Commandcenter
    }
    
    //MARK: Data Loading
    //Ruft alle Stationen über den DataManager ab und speichert sie in allStations.
    func loadStations(completion: @escaping () -> Void) {
        DataManager.shared.getAllStations { [weak self] stations in
            DispatchQueue.main.async {
                self?.allStations = stations
                print("Stations geladen: \(stations.count) Sender")
                completion()
            }
        }
    }
    
    /// Teilt die Stationen anhand der Radio-Kategorien auf das Dictionary auf
    func getStations(for category: RadioCategory) -> [RadioStation] {
        return stationsByCategory[category] ?? []
    }
 
    /// Setzt manuell das Reset-Flag zurück, z. B. bei Kategorie-Wechsel
    func allowFilterReset() {
        filtersWereReset = false
    }

    /// aktualisiert filteredStationsByCategory in der StationsView, wenn die Filter- und Sortierfunktionen verwendet werden
    /// Bei der Auswahl einer Radiostation (z.B. nach einer Suche) wird die gefilterte Liste (mit geänderten Indizes) an den Player übergeben
    private func updateFilteredStations(for category: RadioCategory) {
        let filtered = applyFilters(to: category)
        DispatchQueue.main.async {
            self.filteredStationsByCategory[category] = filtered
            print("`filteredStations` für \(category.rawValue) aktualisiert: \(filtered.count) Sender")
        }
    }

    // MARK: - Metadatenverwaltung
    /// Setzt Metadaten zurück, wenn kein Song läuft
    private func resetMetadata() {
        currentTrack = ""
        currentArtist = ""
        currentArtworkURL = nil
        updateLockScreen()
    }

    /// Gibt den Index eines Senders in der Liste zurück, um in der Player-Bedienung zwischen Stationen navigieren zu können
    private func getIndex(of station: RadioStation?) -> Int? {
        guard let station = station else { return nil }
        return stations.firstIndex(of: station)
    }

}

// MARK: Extension Such- und Filterfunktionen
extension StationsManager {
    
    /// Initialisiert die Suchlogik für die StationsView
       private func setupSearch() {
           searchCancellable = $searchText
               .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
               .removeDuplicates()
               .sink { [weak self] text in
                   self?.handleSearchTextChange(text)
               }
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

    /// Aktiviert die Suchfunktion / das Suchfeld
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
    
    /// Wendet in der StationsView die Suchfilter auf die Senderliste an
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
    /// eingeführt, damit das zurücksetzen der Filter beim Lesen einer Kategorie nicht endlos loopt
    func resetFilters() {
        guard !filtersWereReset else { return }
        searchText = ""
        selectedCountry = "Alle"
        sortMode = .grouped
        filtersWereReset = true
        print("Filterkriterien wurden EINMALIG zurückgesetzt.")
    }
    
    /// Wendet die SearchView Filter auf die Senderliste an und gibt filteredStationsByCategory zurück (siehe allStations didSet)
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
                CountryPickerHelper.displayName(for: station.decodedCountry) == selectedCountry
            }
        }

        // Sortierung nach Alphabet (case‑insensitive, lokalisiert)
        switch sortMode {
        case .grouped:
            // nichts – Reihenfolge kommt (z. B.) aus stationsByCategory
            break

        case .alphaAsc:
            results.sort { $0.decodedName.localizedStandardCompare($1.decodedName) == .orderedAscending }

        case .alphaDesc:
            results.sort { $0.decodedName.localizedStandardCompare($1.decodedName) == .orderedDescending }
        }
        return results
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

    /// Sortierlogik für die Kategorien-Listen und Deduplizierung
    /// Nutzt die Funktion filterStations for category, um die Variable stationsByCategory zu befüllen
    func filterUniqueStationsAndSortByCountry(for category: RadioCategory) {
        // 1. Wie gehabt: filtern & Duplikate entfernen
        let filtered  = filterStations(for: category)
        let unique    = filterUniqueStationsByName(filtered)

        // 2. Präferenz‑Country bestimmen
        let preferred: String = {
            if let code = LocationManager.shared.countryCode {
                return code.uppercased()
            }
            return Locale.current.region?.identifier.uppercased() ?? "DE"
        }()

        // 3. Schlüsselwort für die Name‑Suche (default‑Categories)
        let keyword = category.displayName.lowercased()

        // 4. Sortierung
        let sorted = unique.sorted { a, b in
            // 4.1 Region zuerst
            let regionA = (a.countrycode.uppercased() == preferred) ? 0 : 1
            let regionB = (b.countrycode.uppercased() == preferred) ? 0 : 1
            if regionA != regionB { return regionA < regionB }

            // 4.2 Gruppe bestimmen: (nameMatch, extInfo) → 0…3
            func groupIndex(of s: RadioStation) -> Int {
                let nameMatch = s.decodedName.lowercased().contains(keyword)
                let extInfo   = s.hasExtendedInfo
                switch (nameMatch, extInfo) {
                case (true,  true):   return 0  // name + ext
                case (true,  false):  return 1  // name + no‑ext
                case (false, true):   return 2  // tag  + ext
                case (false, false):  return 3  // tag  + no‑ext
                }
            }
            let gA = groupIndex(of: a), gB = groupIndex(of: b)
            if gA != gB { return gA < gB }

            // 4.3 Fallback: Alphabetisch
            return a.decodedName < b.decodedName
        }

        // 5. Speichern
        stationsByCategory[category] = sorted
        print("Kategorie \(category.rawValue): \(sorted.count) Sender sortiert nach Region→Name/Tag→Extended‑Info.")
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
            let keywords = ["info", "nachrichten", "noticias", "actualités", "notizie"]
            nameResults = allStations.filter { station in
                let lowerName = station.decodedName.lowercased()
                return keywords.contains { lowerName.contains($0) }
            }
        case .artistRadio:
            // Für ArtistRadio: Sender, die im Namen "exclusive" enthalten
            nameResults = allStations.filter { station in
                station.decodedName.lowercased().contains("exclusive")
            }
        case .party:
            // Für Party: Sender, die im Namen "festival" oder "party haben"
            let keywords = ["festival", "party"]
            nameResults = allStations.filter { station in
                let lowerName = station.decodedName.lowercased()
                return keywords.contains { lowerName.contains($0) }
            }
        case .recent, .favorites:
            // keine Zusatz‑Name‑Suche für Recent/Favorites
            break
            
        default:
            // für alle anderen Kategorien: nach dem Kategorienamen im decodedName suchen
            let keyword = category.displayName.lowercased()
            nameResults = allStations.filter {
                $0.decodedName.lowercased().contains(keyword)
            }
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

}

// MARK: Kategorie-spezifische Filter (.recents, .favorites)
extension StationsManager {
    
    /// Fragt die favorisierten Stationen anhand der IDs aus dem FavoritesManager ab
    /// nutzt filterStations withIDs
    func filterByFavoriteStations() {
        let favoriteIDs = FavoritesManager.shared.favoriteStationIDs
        filterStations(withIDs: favoriteIDs, for: .favorites)
    }
    
    /// Fragt die zuletzt gehörten Stationen aus dem RecentsManager ab
    /// nutzt filterStations withIDs
    func filterByRecentStations() {
        let recentIDs = RecentsManager.shared.recentStationIDs
        filterStations(withIDs: recentIDs, for: .recent)
    }
    
    /// Aktualisiert sowohl  stationsByCategory als auch filteredStationsByCategory
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

        // Aktualisiere synchron beide Dictionaries
        self.stationsByCategory[category] = sortedStations
        self.filteredStationsByCategory[category] = self.applyFilters(to: category)
        print("\(category.rawValue.capitalized) geladen: \(sortedStations.count) Sender")
    }
    
}

// MARK: Kategorie-spezifische Logik für LocalStations
extension StationsManager {
    /// Sucht lokale Sender und sortiert sie nach Distanz falls Standort verfügbar
    /// Fallback: Regionsbezogene Stationen werden angezeigt (z.B. alle deutschen Stationen)
    func fetchLocalStations() {
        let locationManager = LocationManager.shared
        let allStationsGlobal = self.allStations
        // Hole den Fallback-Ländercode aus der Locale – standardmäßig „de“
        let fallbackCountry = (Locale.current.region?.identifier ?? "de").lowercased()
        
        // Prüfe, ob ein aktueller Standort vorliegt:
        if let _ = locationManager.currentLocation {
            // Standort wurde ermittelt – normale Filterung
            let stationsByProximity = locationManager.filterStationsByProximity(allStationsGlobal, maxDistance: 50000.0)
            print("Sender im Umkreis von 50 km: \(stationsByProximity.count)")
            
            // Versuche, Sender anhand des Bundeslandes zu filtern (falls vorhanden)
            let stationsByState: [RadioStation] = {
                if let state = locationManager.state, !state.isEmpty {
                    return allStationsGlobal.filter { station in
                        guard let stationState = station.state?.lowercased() else { return false }
                        return stationState == state.lowercased()
                    }
                }
                return []
            }()
            print("Sender basierend auf dem Bundesland: \(stationsByState.count)")
            
            // Kombiniere beide Filter-Ergebnisse
            let combinedStations = stationsByProximity + stationsByState
            let uniqueStations = Array(Dictionary(combinedStations.map { ($0.id, $0) },
                                                  uniquingKeysWith: { first, _ in first }).values)
            
            // Falls keine Sender durch Proximity oder State gefunden wurden, als Fallback Sender mit country = fallbackCountry verwenden
            let finalStations: [RadioStation] = uniqueStations.isEmpty
                ? allStationsGlobal.filter { $0.country.lowercased() == fallbackCountry }
                : uniqueStations
            
            // Sortiere die Sender nach Distanz (falls der Standort verfügbar ist)
            let sortedStations = finalStations.sorted { first, second in
                let distanceA = locationManager.getDistanceToStation(station: first) ?? Double.infinity
                let distanceB = locationManager.getDistanceToStation(station: second) ?? Double.infinity
                return distanceA < distanceB
            }
            
            DispatchQueue.main.async {
                self.stationsByCategory[.local] = sortedStations
                print("Kombinierte lokale Sender geladen: \(sortedStations.count) Sender")
            }
            
        } else {
            // Es wurde keine Standortberechtigung erteilt – daher einfach nach countrycode filtern
            let filteredByCountry = allStationsGlobal.filter { station in
                station.countrycode.lowercased() == fallbackCountry
            }
            DispatchQueue.main.async {
                self.stationsByCategory[.local] = filteredByCountry
                print("Lokale Sender (ohne Standort): \(filteredByCountry.count) Sender")
            }
        }
    }
    
    /// Ermittelt aus einer angezeigten Liste mit Radiostationen die verschiedenen Länder für die Filterung nach Land
    func getAvailableCountries(for category: RadioCategory) -> [String] {
        let stations = getStations(for: category)
        // greift auf den CountryPickerHelper zu um lange Ländernamen zu kürzen
        let countries = stations.map { CountryPickerHelper.displayName(for: $0.decodedCountry) }
        return Array(Set(countries)).sorted()
    }

    /// Überprüft, ob die Sender für eine Kategorie bereits geladen wurden
    func isCategoryLoaded(_ category: RadioCategory) -> Bool {
        return stationsByCategory[category] != nil
    }
}

// MARK: Globe Suchfunktion (SearchView)
extension StationsManager {
    /// Kategorieübergreifende Suche in der SearchView
    /// Nutzt die Hilfsfunktion MatchScore
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
            return station.decodedName.lowercased().contains(queryLower) ||
                   (station.decodedTags?.lowercased().contains(queryLower) ?? false)
        }
        
        let uniqueStations = filterUniqueStationsByName(results)
        
        // Sortiere die Treffer nach Score (bessere Übereinstimmung zuerst) und danach alphabetisch
        let sortedStations = uniqueStations.sorted { station1, station2 in
            let score1 = matchScore(for: station1, query: queryLower)
            let score2 = matchScore(for: station2, query: queryLower)
            if score1 == score2 {
                return station1.decodedName.localizedCaseInsensitiveCompare(station2.decodedName) == .orderedAscending
            }
            return score1 < score2
        }
        
        DispatchQueue.main.async {
            self.searchedStations = sortedStations
            self.currentSearchResults = sortedStations
            completion()
        }
    }
    
    /// berechnet für RadioStationen einen Such-Score, um relavante Radiostationen zuerst anzuzeigen
    private func matchScore(for station: RadioStation, query: String) -> Int {
        let name = station.decodedName.lowercased()
        let tags = station.decodedTags?.lowercased() ?? ""
        
        // Exakter Volltreffer im Namen
        if name == query {
            return 0
        }
        // Name beginnt mit dem Suchtext
        else if name.hasPrefix(query) {
            return 1
        }
        // Name enthält den Suchtext
        else if name.contains(query) {
            return 2
        }
        // Falls die Tags den Suchtext enthalten, gib einen etwas höheren Score zurück
        else if tags.contains(query) {
            return 3
        }
        // Kein Treffer (sollte in der Filterung nicht vorkommen, da wir nur passende Sender haben)
        else {
            return 4
        }
    }
}

//MARK: Extension Sleeptimer
extension StationsManager {

    func startSleepTimer(minutes: Int) {
        stopSleepTimer()
        isSleepTimerActive = true
        sleepTimerRemainingTime = minutes * 60

        sleepTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let timeLeft = self.sleepTimerRemainingTime,
                  timeLeft > 0 else {
                self?.stopSleepTimer()
                self?.pausePlayback()
                return
            }
            self.sleepTimerRemainingTime = timeLeft - 1
        }
    }

    func stopSleepTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        isSleepTimerActive = false
        sleepTimerRemainingTime = nil
    }
}

// MARK: Player-Bedienung
extension StationsManager {
    
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
    
    /// Funktionen zur Playerbedienung über das Commandcenter
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
}

// MARK: Übermittlung der RadioStationen an den Player
extension StationsManager {
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

    /// Legt die aktuelle Navigationliste fest und bereitet den Player vor
    func prepareForPlayback(station: RadioStation, in list: [RadioStation]) {
        // Nur aktualisieren, wenn ein neuer Sender ausgewählt wurde
        if currentStation?.id != station.id {
            set(station: station)
            // Speichere den Snapshot für die Navigation nur beim Wechsel des Senders
            currentNavigationList = list
            currentIndex = list.firstIndex { $0.id == station.id }
            print("PlayerView: currentIndex gesetzt auf \(currentIndex ?? -1)")
        }
        RecentsManager.shared.addRecentStation(station.id)              // Recents-Liste wird aktualisiert
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

}

// MARK: Metadaten Handling mit FRadioPlayer
extension StationsManager {
    /// Wird aufgerufen, wenn Metadaten sich ändern (Songtitel & Künstler)
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        DispatchQueue.main.async {
            // Speichere bisherige Werte
            _ = self.currentArtist
            _ = self.currentTrack

            // Ungültige Werte, die manche Radiosender während Werbung oder Pausen senden
            let invalidValues: Set<String> = ["true", "false", "unknown", "advertisement", "ads", "ad break"]

            // Gibberish-Muster, z. B. wenn der Text keine Leerzeichen enthält und länger als 20 Zeichen ist
            func isLikelyGibberish(_ text: String) -> Bool {
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                return !trimmed.contains(" ") && trimmed.count > 20
            }

            // Hilfsfunktion: erkennt, ob der Text komplett in {} steht
            func isWrappedInBraces(_ text: String) -> Bool {
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.first == "{" && trimmed.last == "}"
            }

            // Bereinige Artist und Track (nur zum Vergleichen)
            let cleanedArtist = artistName?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
            let cleanedTrack  = trackName?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""

            // Standardwerte für Artist und Track
            var displayArtist = self.currentStation?.name ?? "Unbekannter Sender"
            var displayTrack  = NSLocalizedString("Jetzt läuft...", comment: "Fallback-Titel, wenn kein Trackname verfügbar ist")

            // ARTIST-Logik
            if cleanedArtist.contains("gzip")
                || invalidValues.contains(cleanedArtist)
                || (artistName != nil && isWrappedInBraces(artistName!)) {
                // Fallback: use station name
                displayArtist = self.currentStation?.name ?? "Unbekannter Sender"
            } else if let artist = artistName, !artist.isEmpty {
                displayArtist = artist.fixEncoding()
            }

            // TRACK-Logik
            if cleanedTrack.contains("gzip")
                || invalidValues.contains(cleanedTrack)
                || (trackName != nil && isWrappedInBraces(trackName!))
                || isLikelyGibberish(cleanedTrack) {
                // displayTrack bleibt bei "Jetzt läuft..."
            } else if let track = trackName, !track.isEmpty {
                displayTrack = track.fixEncoding()
            }

            // Falls nichts Neues, abbrechen
            if self.currentArtist == displayArtist && self.currentTrack == displayTrack {
                return
            }

            // Werte aktualisieren
            self.currentArtist = displayArtist
            self.currentTrack  = displayTrack
            print("Jetzt läuft: \(self.currentArtist) - \(self.currentTrack)")

            // Albumcover abrufen
            self.fetchAlbumArtwork()
        }
    }

    /// Holt das Albumcover von iTunes oder Musicbrainz (Fallback)
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

    /// Aktualisiert Metadaten auf dem Sperrbildschirm
    private func updateLockScreen() {
        // Fallback-Werte definieren:
        // Wenn z. B. currentArtist leer ist, nutze den Sendernamen.
        // Wenn currentTrack leer ist, zeige "Jetzt läuft...".
        let displayArtist = currentArtist.isEmpty ? (currentStation?.name ?? "Unbekannter Sender") : currentArtist
        let displayTrack = currentTrack.isEmpty ? "Jetzt läuft..."  : currentTrack

        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: displayTrack,
            MPMediaItemPropertyArtist: displayArtist
        ]
        
        // Prüfe, ob ein Albumcover verfügbar ist
        if let artworkURL = currentArtworkURL {
            DispatchQueue.global(qos: .background).async {
                if let data = try? Data(contentsOf: artworkURL),
                   let image = UIImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    DispatchQueue.main.async {
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                    }
                } else {
                    // Falls das Bild nicht abgerufen werden kann: Fallback-Bild verwenden.
                    DispatchQueue.main.async {
                        if let fallbackImage = UIImage(named: "logo_square") {
                            let artwork = MPMediaItemArtwork(boundsSize: fallbackImage.size) { _ in fallbackImage }
                            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                        }
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                    }
                }
            }
        } else {
            // Kein Albumcover verfügbar – standardmäßig ein Systembild verwenden
            if let fallbackImage = UIImage(named: "logo_square") {
                let artwork = MPMediaItemArtwork(boundsSize: fallbackImage.size) { _ in fallbackImage }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    
    /// reagiert auf Änderungen im allgemeinen Player-Zustand und gibt lediglich den neuen Zustand per Print aus
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        print("Player State geändert: \(state)")
        DispatchQueue.main.async {
          self.isBuffering = (state == .loading)
        }
    }

    /// reagiert speziell auf Änderungen im Wiedergabezustand und aktualisiert zusätzlich die Eigenschaft isPlaying im Main-Thread, sodass die UI entsprechend reagiert.
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        print("Playback State geändert: \(state)")
        DispatchQueue.main.async {
            self.isPlaying = (state == .playing)
        }
    }

    /// reagiert auf Änderungen in den Metadaten bezüglich des Albumcovers und gibt den neuen Zustand weiter, damit das neue Cover abgefragt werden kann.
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

