//
//  StubURLProtocol.swift
//  Radio_Sphere
//
// simulierte API-Antwort

import XCTest
@testable import Radio_Sphere

// StubURLProtocol fängt alle URLRequests ab und liefert vorgegebene Antworten.
class StubURLProtocol: URLProtocol {
    /// Hier legen wir fest, welche Daten zurückgegeben werden sollen.
    static var stubResponseData: Data?
    /// Hier legen wir optional einen Fehler fest.
    static var stubError: Error?
    /// Optional: definierte HTTP-Statuscode (Standard 200)
    static var responseStatusCode: Int = 200

    override class func canInit(with request: URLRequest) -> Bool {
        // Alle Anfragen abfangen
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = StubURLProtocol.stubError {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: StubURLProtocol.responseStatusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            if let data = StubURLProtocol.stubResponseData {
                client?.urlProtocol(self, didLoad: data)
            }
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        // Nicht benötigt in diesem einfachen Beispiel.
    }
}

final class RadioAPITests: XCTestCase {

    // Konfiguration einer eigenen URLSession-Konfiguration, die den StubURLProtocol nutzt.
    var session: URLSession!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        session = URLSession(configuration: config)

        // Wichtig: Da RadioAPI aktuell URLSession.shared nutzt, registrieren wir unseren Stub global.
        URLProtocol.registerClass(StubURLProtocol.self)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(StubURLProtocol.self)
        session = nil
        StubURLProtocol.stubResponseData = nil
        StubURLProtocol.stubError = nil
        StubURLProtocol.responseStatusCode = 200
        super.tearDown()
    }

    /// Testet, ob fetchAllStations() eine korrekt decodierte Station zurückliefert.
    func testFetchAllStations() {
        // Dummy JSON, das ein Array mit einem RadioStation-Objekt enthält.
        let dummyJSON = """
        [
            {
                "stationuuid": "1",
                "name": "Test Station",
                "url_resolved": "https://example.com/stream",
                "country": "DE",
                "countrycode": "DE",
                "state": null,
                "language": "de",
                "tags": "pop",
                "lastcheckok": 1,
                "favicon": null,
                "codec": null,
                "clickcount": 100,
                "has_extended_info": false,
                "geo_lat": null,
                "geo_long": null
            }
        ]
        """.data(using: .utf8)
        StubURLProtocol.stubResponseData = dummyJSON

        let api = RadioAPI()
        // Wir erwarten hier, dass fetchAllStations() aus dem Stub den Dummy-JSON verwendet.
        let expectation = self.expectation(description: "fetchAllStations")
        api.fetchAllStations { stations in
            XCTAssertEqual(stations.count, 1, "Es sollte genau eine Station decodiert werden.")
            XCTAssertEqual(stations.first?.id, "1", "Die erste Station sollte die ID '1' haben.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    /// Testet, ob die paginierte Abfrage (fetchStations(offset:limit:completion:)) funktioniert.
    func testFetchStationsWithPagination() {
        // Dummy JSON für zwei Stationen
        let dummyJSON = """
        [
            {
                "stationuuid": "10",
                "name": "Paginated Station 1",
                "url_resolved": "https://example.com/stream1",
                "country": "DE",
                "countrycode": "DE",
                "state": null,
                "language": "de",
                "tags": "pop",
                "lastcheckok": 1,
                "favicon": null,
                "codec": null,
                "clickcount": 50,
                "has_extended_info": false,
                "geo_lat": null,
                "geo_long": null
            },
            {
                "stationuuid": "20",
                "name": "Paginated Station 2",
                "url_resolved": "https://example.com/stream2",
                "country": "DE",
                "countrycode": "DE",
                "state": null,
                "language": "de",
                "tags": "rock",
                "lastcheckok": 1,
                "favicon": null,
                "codec": null,
                "clickcount": 75,
                "has_extended_info": false,
                "geo_lat": null,
                "geo_long": null
            }
        ]
        """.data(using: .utf8)
        StubURLProtocol.stubResponseData = dummyJSON

        let api = RadioAPI()
        let expectation = self.expectation(description: "fetchStations with pagination")
        api.fetchStations(offset: 1000, limit: 2) { stations in
            XCTAssertEqual(stations.count, 2, "Es sollten zwei Stationen decodiert werden.")
            XCTAssertEqual(stations.first?.id, "10", "Die erste Station sollte die ID '10' haben.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
}
