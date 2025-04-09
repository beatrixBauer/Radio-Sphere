//
//  FavoritesManager.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 12.04.25.
//


import Foundation


// MARK: Verwalten die Favorisierten Sender

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()

    // Speicherung der UUIDs der gelikten Stationen
    @Published var favoriteStationIDs: [String] = []

    private let favoritesKey = "favoriteStationIDs"

    private init() {
        loadFavorites()
    }

    // Favorit hinzufügen
    func addFavorite(station: RadioStation) {
        guard !favoriteStationIDs.contains(station.id) else { return }
        favoriteStationIDs.insert(station.id, at: 0)
        saveFavorites()
        
        print("Favorit hinzugefügt: \(station.name) [ID: \(station.id)]")
        print("Aktuelle Favoriten: \(favoriteStationIDs)")
    }

    // Favorit entfernen
    func removeFavorite(station: RadioStation) {
        favoriteStationIDs.removeAll { $0 == station.id }
        saveFavorites()
        
        print("Favorit entfernt: \(station.name) [ID: \(station.id)]")
        print("Aktuelle Favoriten: \(favoriteStationIDs)")
    }

    // Prüfen, ob eine Station bereits favorisiert ist
    func isFavorite(station: RadioStation) -> Bool {
        return favoriteStationIDs.contains(station.id)
    }

    // Favoriten in UserDefaults speichern
    private func saveFavorites() {
        UserDefaults.standard.set(favoriteStationIDs, forKey: favoritesKey)
    }

    // Favoriten aus UserDefaults laden
    private func loadFavorites() {
        favoriteStationIDs = UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
    }
}
