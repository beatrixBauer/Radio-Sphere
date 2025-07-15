//
//  FavoritesListView.swift
//  Radio_Sphere
//


import SwiftUI

// MARK: Favorites-Kategorie bekommt ein swipeToDelete
// so können favorisierte Sender direkt aus der Favoriten-Liste gelöscht werden,
// ohne den Player aufzurufen und das Herzchen zu entfernen

struct FavoritesListView: View {
    @StateObject private var manager = StationsManager.shared
    var filteredStations: [RadioStation]
    var updateFilteredStations: () -> Void

    var body: some View {
        List {
            ForEach(Array(filteredStations.enumerated()), id: \.element.id) { index, station in
                StationRow(
                    station: station,
                    index: index,
                    filteredStations: filteredStations,
                    categoryDisplayName: "Favoriten",
                    isActive: station.id.lowercased() == manager.currentStation?.id.lowercased()
                )
                .listRowBackground(Color.clear)
                // Padding von 50 für den letzten Eintrag hinzufügen
                .padding(.bottom, index == filteredStations.count - 1 ? 80 : 0)
            }
            .onDelete { offsets in
                for index in offsets {
                    let station = filteredStations[index]
                    FavoritesManager.shared.removeFavorite(station: station)
                }
                updateFilteredStations()
            }
        }
    }
}
