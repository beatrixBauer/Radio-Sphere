//
//  SearchView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.04.25.
//

import SwiftUI

// MARK: Globale Suchoberfläche - Kategorieübergreifend

struct SearchView: View {
    @ObservedObject private var manager = StationsManager.shared
    @State private var isSearching: Bool = false
    @State private var searchCompleted: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Liste mit Suchergebnissen (wenn welche vorhanden sind)
                if !manager.searchedStations.isEmpty {
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
                        }
                    }
                    .listStyle(.plain)
                }
                // Ladeanimation während der Suche
                else if isSearching {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Suche läuft…")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
                }
                // Overlay, wenn keine Ergebnisse vorliegen
                else if manager.searchedStations.isEmpty {
                    if searchCompleted {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                            Text("Leider nichts gefunden")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "music.note.list")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                            Text("Finde deinen Rhythmus…")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .applyBackgroundGradient()
            .navigationTitle("Suche")
            .searchable(text: $manager.globalSearchText, prompt: "Sender suchen")
            .onSubmit(of: .search) {
                // Wenn der Nutzer die Suche abschickt, starte den API-Aufruf
                isSearching = true
                searchCompleted = false
                manager.performGlobalSearch {
                    isSearching = false
                    searchCompleted = true
                }
            }
            .onChange(of: manager.globalSearchText) { oldValue, newValue in
                // Leere Suchergebnisse, wenn das Suchfeld geleert wird (z.B. beim Cancel)
                if newValue.isEmpty {
                    manager.searchedStations = []
                    searchCompleted = false
                    isSearching = false
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}




#Preview {
    SearchView()
}
