//
//  MainView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 20.04.25.
//

import SwiftUI

// MARK: ContentView und StationsView werden in die MainView integriert
// Dadurch sind die Tabs (Suche, Favoriten etc. Viewübergreifend verfügbar

struct MainView: View {
    @State private var selectedTab = 0 // Speichert den aktiven Tab
    @ObservedObject private var manager = StationsManager.shared
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    @State private var activeStation: RadioStation? = nil
    @State private var showNoConnectionAlert = false
    
    init() {
        if ProcessInfo.processInfo.arguments.contains("UITest_NoInternet") {
            // Simuliere keine Internetverbindung, damit der Alert erscheint.
            networkMonitor.isConnected = false
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                ContentView()
                    .tabItem {
                        Image(selectedTab == 0 ? "houseFill" : "houseEmpty")
                        Text("Hörwelten")
                    }
                    .tag(0)

                SearchView()
                    .tabItem {
                        Image(selectedTab == 1 ? "searchSparkle" : "searchEmpty")
                        Text("Search")
                    }
                    .tag(1)

                StationsView(category: RadioCategory.favorites)
                    .tabItem {
                        Image(selectedTab == 2 ? "starFill" : "starEmpty")
                        Text("Favoriten")
                    }
                    .tag(2)

                StationsView(category: RadioCategory.recent)
                    .tabItem {
                        Image(selectedTab == 3 ? "recentFill" : "recentEmpty")
                        Text("zuletzt gehört")
                    }
                    .tag(3)
            }
            // MiniPlayerView nur anzeigen, wenn aktiv und nicht in PlayerView
            if manager.isPlaying, !manager.isInPlayerView, manager.currentStation != nil {
                MiniPlayerView {
                    activeStation = manager.currentStation
                }
                .padding(.bottom, 50)
                .transition(.move(edge: .bottom))
            }
        }
        .sheet(item: $activeStation) { station in
            PlayerView(
                station: station,
                filteredStations: manager.currentNavigationList,
                categoryTitle: "Jetzt läuft",
                isSheet: true
            )
        }
        // Netzwerkstatus beobachten: wenn die Verbindung verloren geht, Alert anzeigen
        .onReceive(networkMonitor.$isConnected) { isConnected in
            if !isConnected {
                showNoConnectionAlert = true
            } else {
                showNoConnectionAlert = false
            }
        }
        .alert("Keine Internetverbindung", isPresented: $showNoConnectionAlert) {
            Button("OK", role: .cancel) {
                showNoConnectionAlert = false
            }
        } message: {
            Text("Für die Nutzung der RadioApp ist eine Internetverbindung notwendig. Bitte verbinde dich mit dem Internet.")
        }
        .onChange(of: selectedTab) { newValue in
            print("Aktiver Tab gewechselt: \(newValue)")
        }
        .tint(.white)
        .environment(\.selectedTab, $selectedTab)
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }
        .preferredColorScheme(.dark)
    }
}


#Preview {
    MainView()
}
