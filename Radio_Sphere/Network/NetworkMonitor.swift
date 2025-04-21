//
//  NetworkMonitor.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 27.04.25.
//

import Network
import Combine

/// Überprüfung der Internetverbindung beim Start der App -> wird von SplashView aufgerufen
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    @Published var isConnected: Bool = false
    @Published var connectionType: NWInterface.InterfaceType?

    private init() {}

    // MARK: Startet die Netzwerküberwachung
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                // Online/Offline-Status
                self?.isConnected = (path.status == .satisfied)

                // Unterscheide Mobilfunk (teuer) vs. WLAN/Ethernet (günstig)
                if path.isExpensive {
                    // teure Verbindung = Mobilfunk (oder Hotspot über Mobilfunk)
                    self?.connectionType = .cellular
                } else {
                    // günstige Verbindung = WLAN / Ethernet
                    self?.connectionType = .wifi
                }

                if path.status == .satisfied {
                    print("Netzwerkverbindung besteht. (isExpensive: \(path.isExpensive))")
                } else {
                    print("Keine Netzwerkverbindung.")
                }
            }
        }
        monitor.start(queue: queue)
        print("Netzwerkmonitor gestartet.")
    }

    /// Stoppt die Netzwerküberwachung
    func stopMonitoring() {
        monitor.cancel()
        print("Netzwerkmonitor gestoppt.")
    }
    
}

