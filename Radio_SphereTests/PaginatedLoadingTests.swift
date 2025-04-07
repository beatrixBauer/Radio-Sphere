class PaginatedLoadingTests: XCTestCase {

override func setUp() {
    super.setUp()
    // Registriere unseren Mock für alle URLSession-Anfragen
    URLProtocol.registerClass(MockURLProtocol.self)
    
    // Simuliere eine Mobilfunkverbindung, damit der DataManager den paginierten Zweig wählt
    NetworkMonitor.shared.connectionType = .cellular
    
    // Entferne ggf. vorhandene Stationsdaten, um einen sauberen Zustand zu haben
    let fileManager = FileManager.default
    let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = docsURL.appendingPathComponent("stations.json")
    try? fileManager.removeItem(at: fileURL)
}

override func tearDown() {
    URLProtocol.unregisterClass(MockURLProtocol.self)
    super.tearDown()
}

func testPaginatedLoading() {
    // Konfiguriere den Request-Handler, der abhängig vom Offset verschiedene JSON-Antworten liefert.
    MockURLProtocol.requestHandler = { request in
        guard let url = request.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        
        // Lese den "offset"-Parameter aus der URL (Standard: 0)
        let offsetItem = components.queryItems?.first(where: { $0.name == "offset" })
        let offsetString = offsetItem?.value ?? "0"
        let offset = Int(offsetString) ?? 0
        
        var stationsArray: [[String: Any]] = []
        
        if offset == 0 {
            // Erste Seite: 3 Sender
            stationsArray = [
                ["stationuuid": "station1",
                 "name": "Station 1",
                 "url_resolved": "http://example.com/1",
                 "country": "Testland",
                 "countrycode": "TL",
                 "language": "en",
                 "lastcheckok": 1,
                 "clickcount": 100],
                ["stationuuid": "station2",
                 "name": "Station 2",
                 "url_resolved": "http://example.com/2",
                 "country": "Testland",
                 "countrycode": "TL",
                 "language": "en",
                 "lastcheckok": 1,
                 "clickcount": 100],
                ["stationuuid": "station3",
                 "name": "Station 3",
                 "url_resolved": "http://example.com/3",
                 "country": "Testland",
                 "countrycode": "TL",
                 "language": "en",
                 "lastcheckok": 1,
                 "clickcount": 100]
            ]
        } else if offset == 1000 {
            // Zweite Seite: 2 Sender
            stationsArray = [
                ["stationuuid": "station4",
                 "name": "Station 4",
                 "url_resolved": "http://example.com/4",
                 "country": "Testland",
                 "countrycode": "TL",
                 "language": "en",
                 "lastcheckok": 1,
                 "clickcount": 100],
                ["stationuuid": "station5",
                 "name": "Station 5",
                 "url_resolved": "http://example.com/5",
                 "country": "Testland",
                 "countrycode": "TL",
                 "language": "en",
                 "lastcheckok": 1,
                 "clickcount": 100]
            ]
        } else {
            // Ab Offset 2000: keine Sender (Ende der Pagination)
            stationsArray = []
        }
        
        let data = try JSONSerialization.data(withJSONObject: stationsArray, options: [])
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, data)
    }
    
    let initialExpectation = expectation(description: "Initialer Abruf abgeschlossen")
    let paginationExpectation = expectation(description: "Pagination abgeschlossen")
    
    // Starte den Abruf aller Sender – im Mobilfunkzweig wird paginiert
    DataManager.shared.getAllStations { stations in
        // Der erste Remote-Aufruf liefert die erste Seite (3 Sender)
        XCTAssertEqual(stations.count, 3, "Der initiale Abruf sollte 3 Sender liefern.")
        initialExpectation.fulfill()
    }
    
    wait(for: [initialExpectation], timeout: 5.0)
    
    // Warte kurz, damit die paginierte Abfrage (im Hintergrund) abgeschlossen werden kann.
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        let savedStations = DataManager.shared.loadStationsFromDocuments()
        XCTAssertEqual(savedStations.count, 5, "Nach der Pagination sollten insgesamt 5 Sender gespeichert sein.")
        paginationExpectation.fulfill()
    }
    
    wait(for: [paginationExpectation], timeout: 5.0)
}

}