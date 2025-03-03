//
//  StationsView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.02.25.
//

import SwiftUI

struct StationsView: View {
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
            .navigationTitle("Radiosender")
            .searchable(text: $manager.searchText, prompt: "Sender suchen")
            .autocorrectionDisabled()
            .animation(.default, value: manager.searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        manager.alphabetical.toggle()
                    }) {
                        Label("Abc", systemImage: manager.alphabetical ? "textformat.abc" : "textformat.abc")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Land", selection: $manager.selectedCountry.animation()) {
                            Text("Alle").tag("Alle")
                            ForEach(Array(Set(manager.stations.map { $0.country }).sorted()), id: \.self) { country in
                                Text(country).tag(country)
                            }
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
        .onAppear {
            manager.fetchStations()
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
    StationsView()
}
