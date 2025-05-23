//
//  NetworkMonitor.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 27.04.25.
//

import Network
import Combine

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
    }

    // MARK: - Netzwerküberwachung stoppen
    func stopMonitoring() {
        monitor.cancel()
        print("Netzwerkmonitor gestoppt.")
    }
}
