//
//  StationsManagerTests.swift
//  Radio_Sphere
//
// Test Such- und Duplikatsfilter

import XCTest
@testable import Radio_Sphere

final class StationsManagerTests: XCTestCase {

    var manager: StationsManager!

    override func setUp() {
        super.setUp()
        // Verwende den Singleton und setze die Zustände zurück
        manager = StationsManager.shared
        manager.allStations = []
        manager.stationsByCategory = [:]
        manager.filteredStationsByCategory = [:]
        manager.searchText = ""
        manager.searchActive = false
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    func testFilterUniqueStationsByName() {
        let station1 = RadioStation(testID: "1", testName: "Test Station A", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")

        // Eine Station mit gleichem Namen, aber anderer ID
        let station2 = RadioStation(testID: "2", testName: "Test Station A", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")

        let station3 = RadioStation(testID: "3", testName: "Test Station B", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")

        let stations = [station1, station2, station3]

        let uniqueStations = manager.filterUniqueStationsByName(stations)
        XCTAssertEqual(uniqueStations.count, 2, "Es sollten 2 eindeutige Stationen vorhanden sein.")
    }

    func testApplyFiltersWithSearch() {
        // Setze eine Testkategorie und Stationen
        let category = RadioCategory.pop
        let stationPop = RadioStation(
            testID: "1",
            testName: "Pop Station",
            testTags: "pop",
            testCountry: "Germany",
            testCountryCode: "DE")
        let stationRock = RadioStation(
            testID: "1",
            testName: "Rock Station",
            testTags: "rock",
            testCountry: "Germany",
            testCountryCode: "DE")
        manager.stationsByCategory[category] = [stationPop, stationRock]
        manager.searchActive = true
        manager.searchText = "pop"

        let filtered = manager.applyFilters(to: category)
        XCTAssertEqual(filtered.count, 1, "Es sollten nur 1 Station nach Filterung übrig bleiben.")
        XCTAssertEqual(filtered.first?.id, stationPop.id, "Die gefilterte Station sollte die Pop Station sein.")
    }
}
