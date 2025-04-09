//
//  StationRow.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.04.25.
//


import SwiftUI



// MARK: Händelt, wie eine ausgewählte Station an den Player übergeben wird

struct StationRow: View {
    let station: RadioStation
    let index: Int
    let filteredStations: [RadioStation]
    let categoryDisplayName: String
    let isActive: Bool

    var body: some View {
        
        // Erzeugt eine PlayerView als Variable
        // Das vorherige Entpacken verhindert, dass die View zuviel rechnen muss und abstürzt
        
        let playerView = PlayerView(
            station: station,
            filteredStations: filteredStations,
            categoryTitle: categoryDisplayName,
            isSheet: false
        )
        
        return NavigationLink(destination: playerView) {
            StationCardView(station: station)
        }
        .activeRowBackground(isActive: isActive)
        .background(Color.clear)
        .padding(.horizontal)
        .listRowInsets(EdgeInsets())
    }
}
