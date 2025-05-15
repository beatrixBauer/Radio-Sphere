//
//  SplashView.swift
//  Radio_Sphere
//

import SwiftUI

struct SplashView: View {
    @State private var isActive              = false
    @State private var showNoConnectionAlert = false
    @State private var hasLoadedStations     = false
    @State private var splashStart           = Date()   // << Start-Zeit merken
    
    private let minSplashTime: TimeInterval  = 5.0      // Globe-Intro ≈ 5 s
    
    @ObservedObject private var net  = NetworkMonitor.shared
    @ObservedObject private var mgr  = StationsManager.shared
    let message = NSLocalizedString("no_connection_message", comment: "")
    var body: some View {
        Group {
            if isActive {
                MainView()
            } else {
                GlobeView()
                    .onAppear {
                        splashStart = Date()             // Zeitpunkt des Starts
                        net.startMonitoring()
                    }
                    .onReceive(net.$isConnected.dropFirst()) { connected in
                        if connected {
                            showNoConnectionAlert = false
                            guard hasLoadedStations == false else { return }
                            hasLoadedStations = true
                            
                            mgr.loadStations {
                                // Warten, bis die Animation beendet ist
                                let elapsed = Date().timeIntervalSince(splashStart)
                                let extra   = max(0, minSplashTime - elapsed)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + extra) {
                                    withAnimation { isActive = true }
                                }
                            }
                        } else {
                            showNoConnectionAlert = true
                        }
                    }
                    .alert("Keine Internetverbindung", isPresented: $showNoConnectionAlert) {
                        Button("Erneut prüfen") {
                            if net.isConnected {
                                // Netz da → Alert endgültig schließen
                                showNoConnectionAlert = false
                            } else {
                                // Noch offline → Alert nach dem automatischen Dismiss gleich neu öffnen
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { //kurze Wartezeit, nach "Erneut prüfen" um Flackereffekt zu vermeiden
                                    if !net.isConnected {   // noch kein Netz?
                                        showNoConnectionAlert = true   // → Alert erneut anzeigen
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
}
