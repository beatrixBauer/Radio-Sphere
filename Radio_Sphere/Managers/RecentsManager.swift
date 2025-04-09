//
//  RecentsManager.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 12.04.25.
//


import Foundation


// MARK: Verwaltet die zuletzt gehörten Stationen

class RecentsManager {
    static let shared = RecentsManager()
    private let maxRecents = 20
    private let storageKey = "recentStationIDs"
    
    var recentStationIDs: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: storageKey)
        }
    }
    
    private init() {}
    
    /// Fügt eine neue Sender-UUID zur Liste der zuletzt gehörten Sender hinzu
    func addRecentStation(_ stationID: String) {
        var recents = recentStationIDs
        
        // Entferne die UUID, falls sie bereits existiert (um doppelte Einträge zu vermeiden)
        recents.removeAll { $0 == stationID }
        
        // Füge die neue UUID an den Anfang der Liste hinzu
        recents.insert(stationID, at: 0)
        
        // Begrenze die Liste auf die maximal erlaubte Anzahl
        if recents.count > maxRecents {
            recents.removeLast()
        }
        
        recentStationIDs = recents
        print("Aktualisierte Liste der zuletzt gehörten Sender: \(recents)")
    }
    
    /// Entfernt alle gespeicherten Einträge
    func clearRecents() {
        recentStationIDs = []
        print("Liste der zuletzt gehörten Sender wurde geleert.")
    }
}
