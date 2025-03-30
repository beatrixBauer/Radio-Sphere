import SwiftUI

struct StationRow: View {
    let station: RadioStation
    let index: Int
    let filteredStations: [RadioStation]
    let categoryDisplayName: String

    var body: some View {
        // Erzeuge die PlayerView außerhalb des Haupt-View-Modifiers, um den Ausdruck zu vereinfachen.
        let playerView = PlayerView(
            station: station,
            filteredStations: filteredStations,
            categoryTitle: categoryDisplayName,
            currentIndex: index,
            isSheet: false
        )
        
        return NavigationLink(destination: playerView) {
            StationCardView(station: station)
        }
        .rowBackground(index: index, totalCount: filteredStations.count)
        .padding(.horizontal)
        .listRowInsets(EdgeInsets())
    }
}
