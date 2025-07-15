//
//  SearchView.swift
//  Radio_Sphere
//

import SwiftUI

// MARK: Globale Suchoberfläche - Kategorieübergreifend

struct SearchView: View {
    @ObservedObject private var manager = StationsManager.shared
    @State private var isSearching      = false
    @State private var searchCompleted  = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(manager.searchedStations.enumerated()), id: \.element.id) { index, station in
                    StationRow(
                        station: station,
                        index: index,
                        filteredStations: manager.searchedStations,
                        categoryDisplayName: "Suche",
                        isActive: station.id.lowercased() == manager.currentStation?.id.lowercased()
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    // verhindert, dass der letzte Eintrag unter die TabBar rutscht
                    .padding(.bottom, index == manager.searchedStations.count - 1 ? 80 : 0)
                }
            }
            .listStyle(.plain)
            .overlay {
                Group {
                    // Lade-Spinner
                    if isSearching {
                        ProgressView("Suche läuft…")
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    // „Nichts gefunden“- bzw. Platzhalter-Overlay
                    else if searchCompleted && manager.searchedStations.isEmpty {
                        EmptyPlaceholder(systemName: "magnifyingglass", text: "Leider nichts gefunden")
                    }
                    else if manager.searchedStations.isEmpty {
                        EmptyPlaceholder(systemName: "music.note.list", text: "Finde deinen Rhythmus")
                    }
                }
            }
            .applyBackgroundGradient()
            .navigationTitle("Suche")
            .searchable(text: $manager.globalSearchText, prompt: "Sender suchen")
            .onSubmit(of: .search) {                      // Suche auslösen
                isSearching     = true
                searchCompleted = false
                manager.performGlobalSearch {
                    isSearching     = false
                    searchCompleted = true
                }
            }
            .onChange(of: manager.globalSearchText) { newValue in
                if newValue.isEmpty {
                    manager.searchedStations = []
                    searchCompleted = false
                    isSearching    = false
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

/// Kleiner Helfer für Platzhalter-Overlays
private struct EmptyPlaceholder: View {
    let systemName: String
    let text: LocalizedStringKey
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .foregroundColor(.gray)
            Text(text)
                .font(.title2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


