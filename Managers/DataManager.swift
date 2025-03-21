//
//  DataManager.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.02.25.

import Foundation
import CoreLocation

enum DataError: Error {
    case urlNotValid, dataNotValid, dataNotFound, httpResponseNotValid
}

typealias StationsResult = Result<[RadioStation], Error>
typealias StationsCompletion = (StationsResult) -> Void

struct DataManager {
    
    private static let api = RadioAPI()
    
    /// Holt Radiosender und verarbeitet die API-Daten
    static func getStations(completion: @escaping ([RadioStation]) -> Void) {
           api.fetchStations(completion: completion)
       }
    
    /// Holt Sender basierend auf Land und verarbeitet sie in verschiedene Listen
    static func getCombinedLocalStations(
        countryCode: String,
        state: String,
        lat: Double,
        lon: Double,
        completion: @escaping ([RadioStation]) -> Void
    ) {
        let dispatchGroup = DispatchGroup()
        var allStations: [RadioStation] = []
        let locationManager = LocationManager.shared
        
        // 1. Abfrage aller Sender im Land
        dispatchGroup.enter()
        api.fetchStationsByCountry(countryCode: countryCode) { stations in
            allStations.append(contentsOf: stations)
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            // 1. Filtere Sender im Umkreis von 100 km basierend auf Geo-Daten in station
            let stationsByProximity = locationManager.filterStationsByProximity(allStations, maxDistance: 50000.0)
            print("Sender im Umkreis von 50 km: \(stationsByProximity.count)")

            // Initialisiere die kombinierte Liste bereits hier
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
    
    /// Holt Favoriten basierend auf ihren UUIDs über die API
    static func getStationsByIDs(_ ids: [String], completion: @escaping ([RadioStation]) -> Void) {
        api.fetchStationsByIDs(ids, completion: completion)
    }
    
    /// Holt Radiosender basierend auf einer Kategorie (API-Abfrage)
    static func getStationsByTag(for category: RadioCategory, completion: @escaping ([RadioStation]) -> Void) {
        api.fetchStationsByTags(category.tags, completion: completion)
    }

    static func searchStationsByName(query: String, completion: @escaping ([RadioStation]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var allResults: [RadioStation] = []

        let searchFields = ["tags"]

        for field in searchFields {
            dispatchGroup.enter()
            api.searchStations(by: field, query: query) { stations in
                allResults.append(contentsOf: stations) // API-Treffer speichern
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            let uniqueResults = Array(Set(allResults)) // Duplikate entfernen

            // Falls die API nichts gefunden hat, verwende eine unscharfe lokale Suche!
            if uniqueResults.isEmpty {
                print("API hat keine Treffer gefunden. Starte lokale unscharfe Suche...")
                let fuzzyResults = localFuzzySearch(query)
                completion(fuzzyResults)
            } else {
                completion(uniqueResults)
            }
        }
    }
    
    private static func localFuzzySearch(_ query: String) -> [RadioStation] {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        return StationsManager.shared.stations.filter { station in
            let normalizedName = station.name.lowercased()
            
            return normalizedName.contains(normalizedQuery) ||  // Direkte Teilübereinstimmung
                   normalizedName.replacingOccurrences(of: "-", with: " ").contains(normalizedQuery) ||  // Bindestrich zu Leerzeichen
                   normalizedName.replacingOccurrences(of: " ", with: "").contains(normalizedQuery) ||  // Leerzeichen entfernen
                   station.tags?.lowercased().contains(normalizedQuery) ?? false  // Suche auch in Tags
        }
    }

}


