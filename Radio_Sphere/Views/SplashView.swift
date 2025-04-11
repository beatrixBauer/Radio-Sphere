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
                    manager.loadStations {
                        // Lese die Launch-Argumente aus, um zu entscheiden, wie lange der SplashScreen angezeigt werden soll.
                        let arguments = ProcessInfo.processInfo.arguments
                        let delay: TimeInterval = arguments.contains("UITest_SplashView") ? 6.0 : 4.0

                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            withAnimation {
                                isActive = true
                            }
                        }
                    }
                    // Falls nach 3 Sekunden immer noch keine Verbindung besteht, zeige den Alert.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        if !networkMonitor.isConnected {
                            showNoConnectionAlert = true
                        }
                    }
                }
                .alert("Keine Internetverbindung", isPresented: $showNoConnectionAlert) {
                    Button("Erneut prüfen") {
                        showNoConnectionAlert = false
                        // Versuche erneut, die Stationen zu laden (Fallback greift hier)
                        manager.loadStations {
                            withAnimation {
                                isActive = true
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
