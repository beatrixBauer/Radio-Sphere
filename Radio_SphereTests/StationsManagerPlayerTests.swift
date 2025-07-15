//
//  StationsManagerPlayerTests.swift
//  Radio_Sphere
//
// Test der Player-Funkionen

import XCTest
@testable import Radio_Sphere

final class StationsManagerPlayerTests: XCTestCase {

    var manager: StationsManager!

    override func setUp() {
        super.setUp()
        manager = StationsManager.shared
        // Resette relevante Eigenschaften
        manager.currentNavigationList = []
        manager.currentIndex = nil
        manager.currentStation = nil
        manager.currentTrack = "Some Track"
        manager.currentArtist = "Some Artist"
        manager.currentArtworkURL = URL(string: "https://example.com/artwork")
        
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    // Testet, ob beim erneuten Setzen des gleichen Senders der Pause-Flag zurückgesetzt wird.
    func testSetSameStation() {
        let station = RadioStation(testID: "1", testName: "Station A", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")
        manager.currentStation = station
        manager.userDidPause = true

        manager.set(station: station)

        // Da derselbe Sender gewählt wurde, wird nur play() aufgerufen und der Pause-Flag auf false gesetzt.
        XCTAssertFalse(manager.userDidPause, "Beim Setzen desselben Senders sollte der Pause-Flag zurückgesetzt werden.")
        XCTAssertEqual(manager.currentStation?.id, station.id, "Die aktuelle Station sollte unverändert bleiben.")
    }

    // Testet, ob beim Wechsel zu einem anderen Sender die Station aktualisiert und die Metadaten zurückgesetzt werden.
    func testSetDifferentStation() {
        let station1 = RadioStation(testID: "1", testName: "Station A", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")
        let station2 = RadioStation(testID: "2", testName: "Station B", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")
        manager.currentStation = station1
        manager.currentTrack = "Vorheriger Song"
        manager.currentArtist = "Vorheriger Artist"
        manager.currentArtworkURL = URL(string: "https://example.com/artworkOld")

        manager.set(station: station2)

        XCTAssertEqual(manager.currentStation?.id, station2.id, "Die aktuelle Station sollte auf die neue Station wechseln.")
        XCTAssertEqual(manager.currentTrack, "", "Die Metadaten (Song) sollten zurückgesetzt werden.")
        XCTAssertEqual(manager.currentArtist, "", "Die Metadaten (Artist) sollten zurückgesetzt werden.")
        XCTAssertNil(manager.currentArtworkURL, "Das Artwork sollte zurückgesetzt werden.")
    }

    // Testet die prepareForPlayback()-Funktion: Es sollte die Navigationliste gesetzt und der Index des ausgewählten Senders bestimmt werden.
    func testPrepareForPlayback() {
        let station1 = RadioStation(testID: "1", testName: "Station A", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")
        let station2 = RadioStation(testID: "2", testName: "Station B", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")
        let station3 = RadioStation(testID: "3", testName: "Station C", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")

        let navList = [station1, station2, station3]
        manager.currentStation = nil
        manager.prepareForPlayback(station: station2, in: navList)

        XCTAssertEqual(manager.currentStation?.id, station2.id, "Der ausgewählte Sender sollte gesetzt werden.")
        XCTAssertEqual(manager.currentNavigationList.count, navList.count, "Die Navigationliste sollte übernommen werden.")
        XCTAssertEqual(manager.currentIndex, 1, "Der Index des Senders sollte korrekt bestimmt werden (hier 1).")
    }

    // Testet die setPrevious() und setNext() Logik.
    func testSetPreviousAndNext() {
        let station1 = RadioStation(testID: "1", testName: "Station A", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")
        let station2 = RadioStation(testID: "2", testName: "Station B", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")
        let station3 = RadioStation(testID: "3", testName: "Station C", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")

        manager.currentNavigationList = [station1, station2, station3]
        manager.currentIndex = 1
        manager.currentStation = station2

        // setPrevious() sollte den Index auf 0 setzen
        manager.setPrevious()
        XCTAssertEqual(manager.currentIndex, 0, "Nach setPrevious() sollte der Index 0 sein.")
        XCTAssertEqual(manager.currentStation?.id, station1.id, "Nach setPrevious() sollte Station A aktiv sein.")

        // setNext() sollte den Index wieder auf 1 setzen
        manager.setNext()
        XCTAssertEqual(manager.currentIndex, 1, "Nach setNext() sollte der Index 1 sein.")
        XCTAssertEqual(manager.currentStation?.id, station2.id, "Nach setNext() sollte Station B aktiv sein.")

        // Teste Randfälle:
        // Wenn currentIndex 0 ist, sollte setPrevious() nicht weiter nach unten gehen.
        manager.currentIndex = 0
        manager.currentStation = station1
        manager.setPrevious()
        XCTAssertEqual(manager.currentIndex, 0, "Bei currentIndex 0 sollte setPrevious() den Index nicht verringern.")

        // Wenn currentIndex am Ende der Liste ist, sollte setNext() den Index nicht erhöhen.
        manager.currentIndex = 2
        manager.currentStation = station3
        manager.setNext()
        XCTAssertEqual(manager.currentIndex, 2, "Am Ende der Liste sollte setNext() den Index nicht erhöhen.")
    }
}
