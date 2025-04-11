//
//  StationsView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 01.04.25.

import SwiftUI

// MARK: Anzeige der Liste mit Radiostationen
// dynamische Anpassung an die Kategorie (RadioCategory)
// Case-Handling in HandleOnAppear()

struct StationsView: View {
    @StateObject private var manager = StationsManager.shared
    let category: RadioCategory
    @State private var isNavigatingToPlayerView = false

    var body: some View {
        NavigationStack {
            let filteredStations = manager.filteredStationsByCategory[category] ?? []
            let toolbarTitle = LocalizedStringKey("Hörwelten")

            Group {

                if category == .favorites {
                    FavoritesListView(filteredStations: filteredStations) {
                        updateFilteredStations()
                    }
                } else {
                    List {
                        ForEach(Array(filteredStations.enumerated()), id: \.element.id) { index, station in
                            StationRow(
                                station: station,
                                index: index,
                                filteredStations: filteredStations,
                                categoryDisplayName: category.displayName,
                                isActive: station.id.lowercased() == manager.currentStation?.id.lowercased()
                            )
                            .listRowBackground(Color.clear)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .applyBackgroundGradient()
            .navigationTitle(category.displayName)
            .navigationBarBackButtonHidden(true)
            .searchable(text: $manager.searchText, prompt: "Sender suchen")
            .autocorrectionDisabled()
            .animation(.default, value: manager.searchText)
            .onChange(of: manager.searchText) { newText in
                if !newText.isEmpty || manager.searchActive {
                    manager.handleSearchTextChange(newText)
                    updateFilteredStations()
                } else {
                    print("Leerer Suchtext ignoriert, um Filter zu behalten.")
                }
            }
            .onChange(of: manager.selectedCountry) { _ in
                updateFilteredStations()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CustomBackButton(
                        title: toolbarTitle,
                        foregroundColor: .white,
                        category: category // die aktuelle Kategorie übergeben
                    )
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        manager.alphabetical.toggle()
                        updateFilteredStations()
                    }) {
                        Label("Abc", systemImage: manager.alphabetical ? "textformat.abc" : "textformat.abc")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Land", selection: $manager.selectedCountry) {
                            Text("Alle").tag("Alle")
                            ForEach(manager.getAvailableCountries(for: category), id: \.self) { country in
                                Text(country).tag(country)
                            }
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .tint(.white)
        }
        .onAppear {
            handleOnAppear()
        }
        .preferredColorScheme(.dark)
    }

    /// Behandelt das Verhalten bei Ansichtserscheinen
    private func handleOnAppear() {

        switch category {
        case .recent:
            manager.filterByRecentStations()
        case .favorites:
            manager.filterByFavoriteStations()
        case .local:
            LocationManager.shared.requestLocation()
            manager.fetchLocalStations()
        default:
            if !manager.isCategoryLoaded(category) {
                manager.filterUniqueStationsAndSortByCountry(for: category)
            }
        }
        // `updateFilteredStations()` erst nach dem Laden ausführen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            updateFilteredStations()
        }
    }

    /// Aktualisiert die gefilterte Liste für die aktuell ausgewählte Kategorie
    private func updateFilteredStations() {
        DispatchQueue.main.async {
            if category == .favorites {
                manager.filterByFavoriteStations()
            } else {
                let filtered = manager.applyFilters(to: category)
                manager.filteredStationsByCategory[category] = filtered
                print("`filteredStations` für \(category.displayName) aktualisiert: \(filtered.count) Sender")
            }
        }
    }

}
