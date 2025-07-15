//
//  MetadataUITests.swift
//  Radio Sphere
//
//  Test
// um zu testen, muss der unten stehende auskommentierte Code in Radio_SphereApp verwendet werden

import XCTest

final class MetadataUITests: XCTestCase {
    
    // Observer beim ersten Zugriff auf die Klasse initialisieren
    private static let summaryObserverBootstrap: Void = {
        _ = TestSummaryObserver.shared          // registriert sich beim XCTestObservationCenter
    }()

    override func setUp() {
        _ = MetadataUITests.summaryObserverBootstrap
        continueAfterFailure = false
    }

    func testMetadataIsVisibleAndCorrect() {
        let app = XCUIApplication()
        app.launchArguments = ["-UITestMode", "-startPlayerView"]
        app.launch()

        let artistLabel = app.staticTexts["ArtistLabel"]
        let trackLabel  = app.staticTexts["TrackLabel"]
        let artwork     = app.images["ArtworkImage"]

        XCTAssertTrue(artistLabel.waitForExistence(timeout: 2))
        XCTAssertTrue(trackLabel.waitForExistence(timeout: 2))
        XCTAssertTrue(artwork.waitForExistence(timeout: 2))

        XCTAssertEqual(artistLabel.label, "Jason Derulo")
        XCTAssertEqual(trackLabel.label , "Glad U Came")

        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "F05_Metadata"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

// für UI-Tests
/*struct Radio_SphereApp: App {
    
    init() {
        if ProcessInfo.processInfo.arguments.contains("-UITestMode") {
            let manager = StationsManager.shared

            manager.currentArtist     = "Jason Derulo"
            manager.currentTrack      = "Glad U Came"
            manager.currentArtworkURL = URL(string: "https://example.com/cover.jpg")
            manager.isMiniPlayerVisible = false
            manager.isPlaying = false

            // Teststation explizit erzeugen
            manager.currentStation = RadioStation(
                id: "eb1930be-f372-11e8-a471-52543be04c81",
                name: "- 1 A - 70er von 1A Radio",
                url: "https://1a-70er.radionetz.de/1a-70er.mp3",
                country: "Germany",
                countrycode: "DE",
                state: "Bayern",
                language: "german",
                tags: "70er,70s,oldies,pop",
                lastcheckok: 1,
                imageURL: "https://www.1aradio.com/logos/1a-70er_600x600.jpg",
                codec: "MP3",
                clickcount: 43,
                hasExtendedInfo: true,
                geo_lat: 50.3115,
                geo_long: 11.923
            )
            
            // Simulierter Wechsel für UI-Test
              DispatchQueue.main.asyncAfter(deadline: .now()) {
                   manager.isPlaying = true
                   print("Testmodus: isPlaying wurde auf true gesetzt")

                   DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                       manager.isPlaying = false
                       manager.currentStation == manager.currentStation
                       print("Testmodus: isPlaying wurde wieder auf false gesetzt")
                   }
               }

        }

    }

    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.arguments.contains("-startPlayerView") {
                let manager = StationsManager.shared
                PlayerView(
                    station: manager.currentStation!,
                    filteredStations: [manager.currentStation!],
                    categoryTitle: "Test",
                    isSheet: false
                )
            } else {
                SplashView()
            }
        }
    }
}*/


