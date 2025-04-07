struct FavoritesListView: View {
    var filteredStations: [RadioStation]
    var updateFilteredStations: () -> Void

    var body: some View {
        List {
            ForEach(Array(filteredStations.enumerated()), id: \.element.id) { index, station in
                StationRow(
                    station: station,
                    index: index,
                    filteredStations: filteredStations,
                    categoryDisplayName: "Favoriten"
                )
                .listRowBackground(Color.clear)
            }
            .onDelete { offsets in
                for index in offsets {
                    let station = filteredStations[index]
                    FavoritesManager.shared.removeFavorite(station: station)
                }
                updateFilteredStations()
            }
        }
        .listStyle(.plain)
    }
}
