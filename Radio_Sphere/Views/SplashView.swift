//
//  SplashView.swift
//  Radio_Sphere
//

// MARK: Ruft die Startanimation auf und prüft die Internetverbindung

import SwiftUI

struct SplashView: View {
    @State private var isActive              = false
    @State private var showNoConnectionAlert = false
    @State private var hasLoadedStations     = false
    @State private var splashStart           = Date()
    
    private let minSplashTime: TimeInterval  = 5.0
    
    @ObservedObject private var net = NetworkMonitor.shared
    @ObservedObject private var mgr = StationsManager.shared
    let message = NSLocalizedString("no_connection_message", comment: "")

    var body: some View {
        Group {
            if isActive {
                MainView()
            } else {
                GlobeView()
                    .onAppear {
                        splashStart = Date()
                        net.startMonitoring()
                    }

                    // A) Netzstatus → Fehlerhinweis anzeigen oder verstecken
                    .onReceive(net.$isConnected.dropFirst()) { connected in
                        showNoConnectionAlert = !connected
                        
                        if connected {
                            // Wenn Verbindung da ist: Ladevorgang starten
                            waitUntilExpensiveIsSetThenLoad()
                        }
                    }

                    // B) Alert bei fehlender Verbindung + Erneut-Prüfen-Logik
                    .alert("Keine Internetverbindung", isPresented: $showNoConnectionAlert) {
                        Button("Erneut prüfen") {
                            if net.isConnected {
                                showNoConnectionAlert = false
                            } else {
                                // Direkt wieder anzeigen
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    if !net.isConnected {
                                        showNoConnectionAlert = true
                                    }
                                }
                            }
                        }
                    } message: {
                        Text(message)
                    }
            }
        }
    }

    // C) Sicherstellen, dass isExpensive gesetzt ist, bevor geladen wird
    private func waitUntilExpensiveIsSetThenLoad() {
        guard hasLoadedStations == false else { return }

        // Warten, bis isExpensive überhaupt einen Wert hat
        guard let expensive = net.isExpensive else {
            print("warte auf isExpensive …")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                waitUntilExpensiveIsSetThenLoad()
            }
            return
        }

        hasLoadedStations = true
        print("Starte loadStations mit isExpensive: \(expensive)")

        mgr.loadStations {
            let elapsed = Date().timeIntervalSince(splashStart)
            let extra = max(0, minSplashTime - elapsed)
            DispatchQueue.main.asyncAfter(deadline: .now() + extra) {
                withAnimation { isActive = true }
            }
        }
    }
}
