//
//  ContentView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 04.04.25.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var manager = StationsManager.shared
    @State private var isInStationsView = false

    // Radiokategorien ohne "Zuletzt gehört" & "Favoriten"
    let categories = RadioCategory.allCases.filter { $0 != .recent && $0 != .favorites }

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16) // 2 Spalten
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(destination: StationsView(category: category)) {
                            CategoryTile(title: category.displayName,
                                         iconName: category.iconName)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 50)
            }
            .onDisappear {
                manager.allowFilterReset()
                manager.resetFilters()
            }
            .navigationTitle(LocalizedStringKey("Hörwelten"))
            .applyBackgroundGradient()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
