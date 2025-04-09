//
//  DataManager.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 07.04.25.

import Foundation

class DataManager {
    
    static let shared = DataManager()
    private let api = RadioAPI()
    
    //MARK: Holt alle Stationen:
    /// a) Bei erfolgreicher Remote-Abfrage werden die Daten als Backup gespeichert.
    /// b) Falls der Remote-Call fehlschlägt, wird versucht, die zuletzt gespeicherte Version aus dem Documents-Verzeichnis zu laden (FileManager)
    /// c) Ist keine lokale Version vorhanden, wird der Fallback aus dem Bundle genutzt (Ressourcen).
    func getAllStations(completion: @escaping ([RadioStation]) -> Void) {
        // Unterscheide anhand des Verbindungstyps
        if NetworkMonitor.shared.connectionType == .cellular {
            // Bei Mobilfunk: erste 1000 Sender abrufen
            api.fetchStations(offset: 0, limit: 1000) { [weak self] initialStations in
                guard let self = self else { return }
                if !initialStations.isEmpty {
                    self.saveStationsToDocuments(stations: initialStations)
                    completion(initialStations)
                    // Starte im Hintergrund die paginierte Abfrage
                    self.fetchAllStationsPaginated(startingFrom: 1000)
                } else {
                    // Remote-Call schlug fehl – lade aus dem Documents-Verzeichnis
                    let localStations = self.loadStationsFromDocuments()
                    if !localStations.isEmpty {
                        completion(localStations)
                    } else {
                        // Fallback: stations.json aus dem Bundle kopieren und erneut laden
                        self.copyStationsFromBundleToDocuments()
                        let fallbackStations = self.loadStationsFromDocuments()
                        completion(fallbackStations)
                    }
                }
            }
        } else {
            // Bei WLAN: vollständige Abfrage
            api.fetchAllStations { [weak self] remoteStations in
                guard let self = self else { return }
                if !remoteStations.isEmpty {
                    self.saveStationsToDocuments(stations: remoteStations)
                    completion(remoteStations)
                } else {
                    let localStations = self.loadStationsFromDocuments()
                    if !localStations.isEmpty {
                        completion(localStations)
                    } else {
                        self.copyStationsFromBundleToDocuments()
                        let fallbackStations = self.loadStationsFromDocuments()
                        completion(fallbackStations)
                    }
                }
            }
        }
    }
    
    // Speichert die Stationen als JSON im Documents-Verzeichnis
    private func saveStationsToDocuments(stations: [RadioStation]) {
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docsURL.appendingPathComponent("stations.json")
        
        do {
            let data = try JSONEncoder().encode(stations)
            try data.write(to: fileURL)
            print("Stationsdaten erfolgreich gespeichert.")
        } catch {
            print("Fehler beim Speichern der Stationsdaten: \(error)")
        }
    }
    
    // Lädt die Stationen aus dem Documents-Verzeichnis
    func loadStationsFromDocuments() -> [RadioStation] {
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docsURL.appendingPathComponent("stations.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            let stations = try JSONDecoder().decode([RadioStation].self, from: data)
            return stations
        } catch {
            print("Fehler beim Laden der Stationsdaten: \(error)")
            return []
        }
    }
    
    // Kopiert stations.json aus dem Bundle in das Documents-Verzeichnis
    func copyStationsFromBundleToDocuments() {
        let fileManager = FileManager.default
        guard let bundleURL = Bundle.main.url(forResource: "stations", withExtension: "json") else {
            print("stations.json konnte im Bundle nicht gefunden werden.")
            return
        }
        
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = docsURL.appendingPathComponent("stations.json")
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: bundleURL, to: destinationURL)
            print("Fallback stations.json erfolgreich in Documents kopiert.")
        } catch {
            print("Fehler beim Kopieren der Fallback-Datei: \(error)")
        }
    }
    
    // MARK: Paginierte Abfrage im Hintergrund
    /// Ruft sukzessive weitere Senderseiten ab, beginnt beim angegebenen Offset und fügt sie der lokalen Kopie hinzu.
    private func fetchAllStationsPaginated(startingFrom offset: Int) {
        let pageLimit = 1000
        api.fetchStations(offset: offset, limit: pageLimit) { [weak self] nextStations in
            guard let self = self else { return }
            if nextStations.isEmpty {
                print("Alle zusätzlichen Sender wurden abgerufen.")
            } else {
                // Lade die bisher gespeicherten Stationen
                var currentStations = self.loadStationsFromDocuments()
                // Füge die neu abgerufenen Sender hinzu
                currentStations.append(contentsOf: nextStations)
                // Entferne Duplikate – vorausgesetzt, RadioStation implementiert Hashable
                let uniqueStations = Array(Set(currentStations))
                self.saveStationsToDocuments(stations: uniqueStations)
                print("Zusätzliche \(nextStations.count) Sender abgerufen, Gesamtanzahl: \(uniqueStations.count)")
                // Rekursiver Aufruf, um die nächste Seite abzurufen
                self.fetchAllStationsPaginated(startingFrom: offset + pageLimit)
            }
        }
    }
}


// MARK: Alte Api-Abfragen
/*
 /// Async-Version, die für eine Liste von IDs die zugehörigen Sender zurückgibt.
func fetchStationsByIDs(_ ids: [String]) async -> [RadioStation] {
     await api.fetchStationsByIDs(ids)
 }
 
 ///Holt Radiosender basierend auf einer Kategorie (API-Abfrage) -> für Musikkategorien
 func getStationsByTag(for category: RadioCategory, completion: @escaping ([RadioStation]) -> Void) {
     api.fetchStationsByTags(category.tags, completion: completion)
 }
 
 // MARK: - Holt Sender basierend auf dem Land und verarbeitet sie in verschiedenen Listen
 func getCombinedLocalStations(
     countryCode: String,
     state: String,
     lat: Double,
     lon: Double,
     completion: @escaping ([RadioStation]) -> Void
 ) {
     let dispatchGroup = DispatchGroup()
     var allStations: [RadioStation] = []
     let locationManager = LocationManager.shared
     
     // Abfrage aller Sender im Land mit dem Country-Code
     dispatchGroup.enter()
     api.fetchStationsByCountry(countryCode: countryCode) { stations in
         allStations.append(contentsOf: stations)
         dispatchGroup.leave()
     }
     
     dispatchGroup.notify(queue: .main) {
         // 1. Filtere Sender im Umkreis von 100 km basierend auf Geo-Daten in station
         let stationsByProximity = locationManager.filterStationsByProximity(allStations, maxDistance: 50000.0)
         print("Sender im Umkreis von 50 km: \(stationsByProximity.count)")

         // Initialisiere die kombinierte Liste
         var combinedStations: [RadioStation] = []
         combinedStations.append(contentsOf: stationsByProximity)

         // 2. Filtere Sender basierend auf dem Bundesland (State-Attribut)
         let stationsByState = allStations.filter { station in
             guard let stationState = station.state?.lowercased() else { return false }
             return stationState == state.lowercased()
         }
         print("Sender basierend auf dem Bundesland: \(stationsByState.count)")
         combinedStations.append(contentsOf: stationsByState)
         
         // Entferne Duplikate und gib die kombinierte Liste zurück
         let uniqueStations = Array(Set(combinedStations))
         completion(uniqueStations)
         print("Kombinierte Sender geladen: \(uniqueStations.count) Sender")
     }
 }
 
 // MARK: - Funktion zur API-Suche nach Stationsnamen
 func searchStationsByName(query: String, completion: @escaping ([RadioStation]) -> Void) {
     let dispatchGroup = DispatchGroup()
     var allResults: [RadioStation] = []

     let searchFields = ["name"]

     for field in searchFields {
         dispatchGroup.enter()
         api.searchStations(by: field, query: query) { stations in
             allResults.append(contentsOf: stations) // API-Treffer speichern
             dispatchGroup.leave()
         }
     }

     dispatchGroup.notify(queue: .main) {
         let uniqueResults = Array(Set(allResults)) // Duplikate entfernen
         completion(uniqueResults)
     }
 }
 
 */

