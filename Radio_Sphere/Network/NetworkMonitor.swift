//
//  NetworkMonitor.swift
//  Radio_Sphere
//

import Network
import Combine
import Foundation

/// Überprüft die Internetverbindung und veröffentlicht Statusänderungen.
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue   = DispatchQueue.global(qos: .background)

    /// `true`, sobald `path.status == .satisfied`
    @Published var isConnected: Bool = false

    /// `.wifi`, `.cellular` … **oder `nil`, wenn kein Netz vorhanden ist**
    @Published var connectionType: NWInterface.InterfaceType?
    
    // um auf Mobilfunkverbindungen zu reagieren
    @Published var isExpensive: Bool? = nil


    private init() { }

    // MARK: - Netzwerküberwachung starten
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.isConnected = (path.status == .satisfied)
                self.isExpensive = path.isExpensive           // ← HIER eingefügt

                if path.status == .satisfied {
                    self.connectionType = path.isExpensive ? .cellular : .wifi
                    print("Netzwerkverbindung besteht. (isExpensive: \(path.isExpensive))")
                } else {
                    self.connectionType = nil
                    print("Keine Netzwerkverbindung.")
                }
            }
        }

        monitor.start(queue: queue)
        print("Netzwerkmonitor gestartet.")
        
        
        #if DEBUG
        // Test-Hook: nach X Sekunden offline für Y Sekunden
        let args = ProcessInfo.processInfo.arguments
        if let afterIdx = args.firstIndex(of: "-UITestOfflineAfter"),
           args.count > afterIdx + 1,
           let after = Double(args[afterIdx + 1]),
           let durIdx = args.firstIndex(of: "-UITestOfflineDuration"),
           args.count > durIdx + 1,
           let duration = Double(args[durIdx + 1]) {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + after) { [weak self] in
                guard let self = self else { return }
                print("🔄 Simuliere Offline für \(duration)s")
                self.isConnected = false
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    self.isConnected = true
                    print(" Offline-Simulation beendet, Netzwerk wieder da")
                }
            }
        }
        #endif
        
    }

    // MARK: - Netzwerküberwachung stoppen
    func stopMonitoring() {
        monitor.cancel()
        print("Netzwerkmonitor gestoppt.")
    }
}
