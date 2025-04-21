//
//  DataManager.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 07.04.25.

import Foundation

class DataManager {

    static let shared = DataManager()
    private let api = RadioAPI()

    // MARK: Holt alle Stationen:
    /// a) Bei erfolgreicher Remote-Abfrage werden die Daten als Backup gespeichert.
    /// b) Falls der Remote-Call fehlschlägt, wird versucht, die zuletzt gespeicherte Version aus dem Documents-Verzeichnis zu laden (FileManager)
    /// c) Ist keine lokale Version vorhanden, wird der Fallback aus dem Bundle genutzt (Ressourcen).
    func getAllStations(completion: @escaping ([RadioStation]) -> Void) {
        let fileManager = FileManager.default
        // Hole die URL im Documents-Verzeichnis
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docsURL.appendingPathComponent("stations.json")
        
        // Überprüfe, ob die Datei existiert und nicht älter als 24 Stunden ist.
        if fileManager.fileExists(atPath: fileURL.path),
           let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
           let modDate = attributes[.modificationDate] as? Date,
           Date().timeIntervalSince(modDate) < 24 * 60 * 60 {
            // Es wird ausschließlich die im Documents-Verzeichnis abgelegte Datei verwendet.
            print("Verwende Sicherheitskopie aus dem Dokumentensystem, da sie nicht älter als 24 Stunden ist.")
            let localStations = loadStationsFromDocuments()
            if !localStations.isEmpty {
                completion(localStations)
                return
            }
        }
        
        // Wenn keine frische Datei im Documents-Verzeichnis vorhanden ist, wird die API-Anfrage ausgelöst.
        if NetworkMonitor.shared.connectionType == .cellular {
            // Bei Mobilfunk: zuerst 5000 Sender laden
            api.fetchStations(offset: 0, limit: 5000) { [weak self] initialStations in
                guard let self = self else { return }

                if !initialStations.isEmpty {
                    // Duplikate entfernen und speichern
                    let uniqueInitial = Array(Set(initialStations))
                    self.saveStationsToDocuments(stations: uniqueInitial)

                    // Erste Sender direkt verfügbar machen
                    DispatchQueue.main.async {
                        StationsManager.shared.allStations = uniqueInitial
                        completion(uniqueInitial) // MainView darf starten
                    }

                    // Hintergrund: restliche Sender nachladen
                    self.fetchAllStationsPaginated(startingFrom: 5000, aggregated: uniqueInitial) { finalStations in
                        DispatchQueue.main.async {
                            StationsManager.shared.allStations = finalStations
                            self.saveStationsToDocuments(stations: finalStations)
                            print("Alle Stationen vollständig geladen: \(finalStations.count)")
                        }
                    }
                } else {
                    // API-Anfrage schlug fehl, versuche aus dem Documents-Verzeichnis zu laden.
                    let backupStations = self.loadStationsFromDocuments()
                    if !backupStations.isEmpty {
                        completion(backupStations)
                    } else {
                        // Fallback: stations.json aus dem Bundle kopieren und erneut laden.
                        self.copyStationsFromBundleToDocuments()
                        let fallbackStations = self.loadStationsFromDocuments()
                        completion(fallbackStations)
                    }
                }
            }
        } else {
            // Bei WLAN: vollständige Abfrage.
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
    private func fetchAllStationsPaginated(startingFrom offset: Int, aggregated: [RadioStation], pageLimit: Int = 5000, completion: @escaping ([RadioStation]) -> Void) {
        api.fetchStations(offset: offset, limit: pageLimit) { [weak self] nextStations in
            guard let self = self else { return }

            var updated = aggregated
            updated.append(contentsOf: nextStations)
            updated = Array(Set(updated))

            // Laufzeit-Update
            DispatchQueue.main.async {
                StationsManager.shared.allStations = updated
                print("Aktueller Stand während Ladevorgang: \(updated.count) Stationen")
            }

            // Beenden, wenn letzte Seite
            if nextStations.count < pageLimit {
                completion(updated)
            } else {
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                    self.fetchAllStationsPaginated(startingFrom: offset + pageLimit, aggregated: updated, pageLimit: pageLimit, completion: completion)
                }
            }
        }
    }

}



