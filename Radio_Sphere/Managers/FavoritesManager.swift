import Foundation

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()

    @Published var favoriteStationIDs: [String] = []

    private let favoritesKey = "favoriteStationIDs"

    private init() {
        loadFavorites()
    }

    // Station zur Favoritenliste hinzufügen
    func addFavorite(station: RadioStation) {
        guard !favoriteStationIDs.contains(station.id) else { return }
        favoriteStationIDs.append(station.id)
        saveFavorites()
    }

    // Station aus der Favoritenliste entfernen
    func removeFavorite(station: RadioStation) {
        favoriteStationIDs.removeAll { $0 == station.id }
        saveFavorites()
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
