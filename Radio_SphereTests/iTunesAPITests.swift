//
//  iTunesAPITests.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 06.05.25.
//


import XCTest
@testable import Radio_Sphere

final class iTunesAPITests: XCTestCase {

    // Wir konfigurieren eine eigene URLSession-Konfiguration, die unseren StubURLProtocol nutzt.
    var session: URLSession!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        session = URLSession(configuration: config)
        // Da iTunesAPI aktuell URLSession.shared verwendet, registrieren wir den Stub global.
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

    func testGetAlbumCover_Success() {
        // Dummy JSON-Antwort für iTunes API
        let dummyJSON = """
        {
           "resultCount": 1,
           "results": [
               {
                   "artworkUrl100": "https://dummyimage.com/100x100/000/fff",
                   "trackViewUrl": "https://itunes.apple.com/track/12345"
               }
           ]
        }
        """.data(using: .utf8)
        StubURLProtocol.stubResponseData = dummyJSON

        let expectation = self.expectation(description: "getAlbumCover")
        iTunesAPI.shared.getAlbumCover(artist: "Test Artist", track: "Test Track") { artworkUrl, trackUrl in
            // Wir erwarten, dass beide URLs nicht nil sind
            XCTAssertNotNil(artworkUrl, "Artwork URL should not be nil")
            XCTAssertNotNil(trackUrl, "Track URL should not be nil")
            
            // Die artworkUrl soll von 100x100 zu 1200x1200 transformiert worden sein
            if let artworkUrl = artworkUrl {
                XCTAssertTrue(artworkUrl.absoluteString.contains("1200x1200"),
                              "Artwork URL should be transformed to high resolution")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    func testGetAlbumCover_Failure() {
        // Simuliere einen Fehler, indem wir einen Stub-Error setzen.
        StubURLProtocol.stubError = NSError(domain: "TestError", code: 1, userInfo: nil)

        let expectation = self.expectation(description: "getAlbumCover error")
        iTunesAPI.shared.getAlbumCover(artist: "Test Artist", track: "Test Track") { artworkUrl, trackUrl in
            // Bei einem Fehler sollten beide URLs nil sein.
            XCTAssertNil(artworkUrl, "Artwork URL should be nil on error")
            XCTAssertNil(trackUrl, "Track URL should be nil on error")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
}
