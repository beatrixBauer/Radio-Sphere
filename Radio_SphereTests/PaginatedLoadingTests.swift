//
//  PaginatedLoadingTests.swift
//  Radio_Sphere
//
// Test des paginierten Ladens

import XCTest

class PaginatedLoadingTests: XCTestCase {
    var radioAPI: RadioAPI!

    override func setUp() {
        super.setUp()

        // Erstelle eine URLSession mit einer ephemeralen Konfiguration und setze den MockURLProtocol
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)

        // Injektion der Test-Session in RadioAPI
        radioAPI = RadioAPI(session: session)

        // Simuliere eine Mobilfunkverbindung, damit der DataManager den paginierten Zweig wählt
        NetworkMonitor.shared.connectionType = .cellular

        // Entferne vorhandene Stationsdaten im Documents-Verzeichnis, damit ein sauberer Zustand vorliegt
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
        // Konfiguriere den Request-Handler, der je nach Offset unterschiedliche JSON-Antworten liefert
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else {
                throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            }

            // Lese den "offset"-Parameter aus der URL (Standardwert: 0)
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
                // Ab Offset 2000: keine Sender – Ende der Pagination
                stationsArray = []
            }

            let data = try JSONSerialization.data(withJSONObject: stationsArray, options: [])
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let initialExpectation = expectation(description: "Initialer Abruf abgeschlossen")
        let paginationExpectation = expectation(description: "Pagination abgeschlossen")

        // Starte den Abruf der ersten Seite
        radioAPI.fetchStations(offset: 0, limit: 1000) { initialStations in
            XCTAssertEqual(initialStations.count, 3, "Der initiale Abruf sollte 3 Sender liefern.")
            initialExpectation.fulfill()

            // Abruf der zweiten Seite
            self.radioAPI.fetchStations(offset: 1000, limit: 1000) { nextStations in
                XCTAssertEqual(nextStations.count, 2, "Der zweite Abruf sollte 2 Sender liefern.")
                // Kombiniere beide Ergebnisse
                let combined = initialStations + nextStations
                XCTAssertEqual(combined.count, 5, "Insgesamt sollten 5 Sender vorhanden sein.")
                paginationExpectation.fulfill()
            }
        }

        wait(for: [initialExpectation, paginationExpectation], timeout: 5.0)
    }
}
