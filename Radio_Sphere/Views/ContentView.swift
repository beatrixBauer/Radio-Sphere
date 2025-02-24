//
//  ContentView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.02.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var manager = StationsManager.shared

    var body: some View {
        NavigationStack {
            let stations = manager.filteredStations()
            
            List(stations.indices, id: \.self) { index in
                let station = stations[index]
                NavigationLink(destination: PlayerView(station: station)) {
                    StationCardView(station: station)
                }
                .listRowBackground(rowBackground(index: index)).padding(.horizontal)
                .listRowInsets(EdgeInsets())
                .listStyle(.plain)
            }
            .searchable(text: $manager.searchText, prompt: "Sender oder Genre suchen")
            .navigationTitle("Radiosender")
            .onAppear {
                manager.fetchStations()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func rowBackground(index: Int) -> some View {
        if index.isMultiple(of: 2) {
            return AnyView(Color.gray.opacity(0.1))
        } else {
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.4),
                        Color.gray.opacity(0.1)
                    ]),
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
            )
        }
    }
}



#Preview {
    ContentView()
}
