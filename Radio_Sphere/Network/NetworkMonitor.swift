import Network

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    @Published var isConnected: Bool = false
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                if path.status == .satisfied {
                    print("Netzwerkverbindung besteht.")
                } else {
                    print("Keine Netzwerkverbindung.")
                }
            }
        }
        monitor.start(queue: queue)
    }
}
