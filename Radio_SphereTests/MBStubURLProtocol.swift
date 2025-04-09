//
//  MBStubURLProtocol.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 06.05.25.
//


import XCTest
@testable import Radio_Sphere

// MARK: MBStubURLProtocol
// Dieser Stub unterscheidet anhand des URL-Hosts zwischen MusicBrainz- und CoverArtArchive-Anfragen.
class MBStubURLProtocol: URLProtocol {
    // StubResponses: Key = Teil des Hostnamens, Value = (data, statusCode, error)
    static var stubResponses: [String: (data: Data?, statusCode: Int, error: Error?)] = [:]
    
    static func reset() {
        stubResponses = [:]
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        // Alle Requests abfangen
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let host = request.url?.host else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        // Suche nach einem passenden Stub anhand des Hostnamens
        for (key, response) in MBStubURLProtocol.stubResponses {
            if host.contains(key) {
                if let error = response.error {
                    client?.urlProtocol(self, didFailWithError: error)
                } else {
                    let httpResponse = HTTPURLResponse(url: request.url!,
                                                       statusCode: response.statusCode,
                                                       httpVersion: nil,
                                                       headerFields: nil)!
                    client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
                    if let data = response.data {
                        client?.urlProtocol(self, didLoad: data)
                    }
                }
                client?.urlProtocolDidFinishLoading(self)
                return
            }
        }
        // Falls kein Stub gefunden wird:
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // Nicht erforderlich
    }
}

// MARK: MusicBrainzAPITests
final class MusicBrainzAPITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Registriere unseren MBStubURLProtocol global
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MBStubURLProtocol.self]
        URLProtocol.registerClass(MBStubURLProtocol.self)
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(MBStubURLProtocol.self)
        MBStubURLProtocol.reset()
        super.tearDown()
    }
    
    /// Testet den Erfolgsfall: Die MusicBrainzAPI soll anhand des Dummy-JSON eine Release-ID extrahieren
    /// und anschließend über CoverArtArchive einen Erfolg simulieren.
    func testGetAlbumCover_Success() {
        // Dummy JSON-Antwort für MusicBrainz: Ein Recording mit einem Release (ID "release123")
        let mbDummyJSON = """
        {
            "recordings": [
                {
                    "releases": [
                        { "id": "release123" }
                    ]
                }
            ]
        }
        """.data(using: .utf8)
        
        // StubResponses für die beiden angefragten Hosts:
        MBStubURLProtocol.stubResponses = [
            // MusicBrainz-Antwort
            "musicbrainz.org": (data: mbDummyJSON, statusCode: 200, error: nil),
            // CoverArtArchive: Wir simulieren einen Erfolg (HTTP 200) – der tatsächliche Body spielt hier keine Rolle,
            // da die Methode nur den Request-URL zurückliefert.
            "coverartarchive.org": (data: nil, statusCode: 200, error: nil)
        ]
        
        let expectation = self.expectation(description: "MusicBrainz getAlbumCover")
        MusicBrainzAPI.shared.getAlbumCover(artistName: "Test Artist", trackTitle: "Test Track") { result in
            switch result {
            case .success(let url):
                // Wir erwarten, dass die URL den erwarteten Pfad enthält
                XCTAssertTrue(url.absoluteString.contains("coverartarchive.org/release/release123/front"),
                              "Die zurückgegebene URL sollte den Release 'release123' enthalten.")
            case .failure(let error):
                XCTFail("Erwarteter Erfolg, aber Fehler erhalten: \(error)")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    /// Testet den Fehlerfall, wenn die MusicBrainz-Antwort keine Aufnahmen enthält.
    func testGetAlbumCover_NoRecordings() {
        // Dummy JSON-Antwort, bei der recordings leer ist
        let emptyMBJSON = """
        {
            "recordings": []
        }
        """.data(using: .utf8)
        MBStubURLProtocol.stubResponses = [
            "musicbrainz.org": (data: emptyMBJSON, statusCode: 200, error: nil)
        ]
        
        let expectation = self.expectation(description: "MusicBrainz no recordings")
        MusicBrainzAPI.shared.getAlbumCover(artistName: "Test Artist", trackTitle: "Test Track") { result in
            switch result {
            case .success:
                XCTFail("Erwarteter Fehler aufgrund fehlender Recordings, aber Erfolg erhalten.")
            case .failure(let error):
                // Hier prüfen wir, ob der Fehler dem erwarteten Fall entspricht.
                if case MusicBrainzError.noRecordingsFound = error {
                    // Erfolg: Fehler wie erwartet
                } else {
                    XCTFail("Erwarteter noRecordingsFound-Fehler, aber anderer Fehler erhalten: \(error)")
                }
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
}
