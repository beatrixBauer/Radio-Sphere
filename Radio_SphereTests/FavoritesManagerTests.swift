//
//  FavoritesManagerTests.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 06.05.25.
//


import XCTest
@testable import Radio_Sphere

final class FavoritesManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset favorites; falls nötig, direkt über UserDefaults manipulieren oder FavoritesManager neu instanziieren
        FavoritesManager.shared.favoriteStationIDs = []
    }

    func testAddAndRemoveFavorite() {
        let manager = FavoritesManager.shared
        let testStation = RadioStation(testID: "station1", testName: "Test Station", testTags: "Pop", testCountry: "Germany", testCountryCode: "DE")


        // Favorit hinzufügen
        manager.addFavorite(station: testStation)
        XCTAssertTrue(manager.favoriteStationIDs.contains(testStation.id), "Die Station sollte favorisiert sein.")

        // Duplikate vermeiden
        manager.addFavorite(station: testStation)
        XCTAssertEqual(manager.favoriteStationIDs.filter { $0 == testStation.id }.count, 1, "Es dürfen keine Duplikate entstehen.")

        // Favorit entfernen
        manager.removeFavorite(station: testStation)
        XCTAssertFalse(manager.favoriteStationIDs.contains(testStation.id), "Die Station sollte nicht mehr in den Favoriten sein.")
    }

    func testIsFavorite() {
        let manager = FavoritesManager.shared
        let testStation = RadioStation(testID: "station1", testName: "Test Station", testTags: "Pop", testCountry: "Germany", testCountryCode: "DE")
        
        XCTAssertFalse(manager.isFavorite(station: testStation), "Die Station sollte noch nicht favorisiert sein.")
        manager.addFavorite(station: testStation)
        XCTAssertTrue(manager.isFavorite(station: testStation), "Die Station sollte jetzt favorisiert sein.")
    }
}



