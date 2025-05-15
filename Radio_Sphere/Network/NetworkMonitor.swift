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

    private init() { }

    // MARK: - Netzwerküberwachung starten
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                guard let self = self else { return }

                // 1. Online/Offline-Status
                self.isConnected = (path.status == .satisfied)

                // 2. Verbindungstyp nur setzen, wenn eine Verbindung besteht
                if path.status == .satisfied {
                    // Teure Verbindung = Mobilfunk; sonst WLAN/Ethernet
                    self.connectionType = path.isExpensive ? .cellular : .wifi
                    print("Netzwerkverbindung besteht. (isExpensive: \(path.isExpensive))")
                } else {
                    // Kein Netz → kein Verbindungstyp
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
