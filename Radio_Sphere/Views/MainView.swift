//
//  MainView.swift
//  Radio_Sphere
//


import SwiftUI

// MARK: ContentView und StationsView werden in die MainView integriert
// Dadurch sind die Tabs (Suche, Favoriten etc. Viewübergreifend verfügbar

struct MainView: View {
    @State private var selectedTab = 0 // Speichert den aktiven Tab
    @ObservedObject private var manager = StationsManager.shared
    @ObservedObject private var net = NetworkMonitor.shared
    @State private var activeStation: RadioStation?
    @State private var showNoConnectionAlert = false
    let message = NSLocalizedString("no_connection_message", comment: "")

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                ContentView()
                    .accessibilityIdentifier("tab_Hörwelten")
                    .tabItem {
                        Image(selectedTab == 0 ? "houseFill" : "houseEmpty")
                        Text("Hörwelten")
                    }
                    .tag(0)

                SearchView()
                    .accessibilityIdentifier("tab_Suche")
                    .tabItem {
                        Image(selectedTab == 1 ? "searchSparkle" : "searchEmpty")
                        Text("Suche")
                    }
                    .tag(1)

                StationsView(category: RadioCategory.favorites)
                    .accessibilityIdentifier("tab_Favoriten")
                    .tabItem {
                        Image(selectedTab == 2 ? "heartSquareFill" : "heartSquare")
                        Text("Favoriten")
                    }
                    .tag(2)

                StationsView(category: RadioCategory.recent)
                    .accessibilityIdentifier("tab_Verlauf")
                    .tabItem {
                        Image(selectedTab == 3 ? "recentFill" : "recentEmpty")
                        Text("zuletzt gehört")
                    }
                    .tag(3)
            }
            // MiniPlayerView nur anzeigen, wenn aktiv und nicht in PlayerView
            if manager.isMiniPlayerVisible, !manager.isInPlayerView, manager.currentStation != nil {
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
        .onReceive(net.$isConnected) { isConnected in
            if !isConnected {
                showNoConnectionAlert = true
            } else {
                showNoConnectionAlert = false
            }
        }
        .alert("Keine Internetverbindung",
               isPresented: $showNoConnectionAlert) {
            Button("Erneut prüfen") {
                if net.isConnected {
                    showNoConnectionAlert = false     // Netz da → schließen
                } else {
                    // sofort neu öffnen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { //kurze Wartezeit, nach "Erneut prüfen" um Flackereffekt zu vermeiden
                        if !net.isConnected {   // noch kein Netz?
                            showNoConnectionAlert = true   // → Alert erneut anzeigen
                        }
                    }
                }
            }
        
        }
        message: {
            Text(message)
        }
        .onChange(of: selectedTab) { newValue in
            print("Aktiver Tab gewechselt: \(newValue)")
            //manager.allowFilterReset()
            //manager.resetFilters()
        }
        .tint(.white)
        .environment(\.selectedTab, $selectedTab)
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }
        .preferredColorScheme(.dark)
    }
}
