//
//  SplashView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 16.04.25.
//

import SwiftUI

// MARK: Startbildschirm und handling der Internet-Statusabfrage
// Leitet zur MainView weiter

struct SplashView: View {
    @State private var isActive = false
    @State private var showNoConnectionAlert = false
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    @ObservedObject private var manager = StationsManager.shared

    var body: some View {
        if isActive {
            MainView()
        } else {
            GlobeView()
                .onAppear {
                    networkMonitor.startMonitoring()
                }
                // Erst wenn die Verbindung steht, laden wir die Stationen
                .onChange(of: networkMonitor.connectionType) { _ in
                    guard networkMonitor.isConnected else { return }
                    manager.loadStations {
                        // Splash‑Delay nach dem Laden
                        let args = ProcessInfo.processInfo.arguments
                        let delay: TimeInterval = args.contains("UITest_SplashView") ? 6 : 4
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            withAnimation { isActive = true }
                        }
                    }
                }
                .alert("Keine Internetverbindung", isPresented: $showNoConnectionAlert) {
                    Button("Erneut prüfen") {
                        showNoConnectionAlert = false
                        // auch hier wieder warten, bis connectionType gesetzt ist
                        if networkMonitor.isConnected {
                            manager.loadStations {
                                withAnimation { isActive = true }
                            }
                        }
                    }
                } message: {
                    Text("Für die Nutzung der RadioApp ist eine Internetverbindung notwendig. Bitte verbinde dich mit dem Internet.")
                }
        }
    }
}


#Preview {
    SplashView()
}
