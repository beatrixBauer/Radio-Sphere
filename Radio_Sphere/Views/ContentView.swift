//
//  ContentView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.02.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var manager = StationsManager.shared
    @State var searchText = ""
    @State var alphabetical = false


    var body: some View {
        NavigationStack {
            List(manager.stations.indices, id: \.self) { index in
                let station = manager.stations[index]
                NavigationLink(destination: PlayerView(station: station)) {
                    StationCardView(station: station)
                }
                .listRowBackground(rowBackground(index: index)).padding(.horizontal)
                .listRowInsets(EdgeInsets())
                .listStyle(.plain)
            }
            .searchable(text: $searchText)
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
