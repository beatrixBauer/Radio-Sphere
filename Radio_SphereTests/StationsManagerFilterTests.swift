//
//  StationsManagerFilterTests.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 06.05.25.
//

import XCTest
@testable import Radio_Sphere

final class StationsManagerFilterTests: XCTestCase {

    var manager: StationsManager!

    override func setUp() {
        super.setUp()
        manager = StationsManager.shared
        // Resetten aller relevanten Zustände, damit Tests isoliert laufen:
        manager.allStations = []
        manager.stationsByCategory = [:]
        manager.filteredStationsByCategory = [:]
        manager.searchText = ""
        manager.searchActive = false
        manager.selectedCountry = "Alle"
        manager.alphabetical = false
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    // Testet, ob beim Filtern nach Kategorie-Tags nur die passenden Stationen zurückgegeben werden.
    func testFilterStationsForCategory() {
        let station1 = RadioStation(testID: "1", testName: "Pop Station", testTags: "pop, music", testCountry: "Germany", testCountryCode: "DE")
        let station2 = RadioStation(testID: "2", testName: "Rock Station", testTags: "rock, alternative", testCountry: "Germany", testCountryCode: "DE")
        let station3 = RadioStation(testID: "3", testName: "Jazz Station", testTags: "jazz", testCountry: "Germany", testCountryCode: "DE")

        // Alle Stationen in manager.allStations bereitstellen
        manager.allStations = [station1, station2, station3]
        // Filtern für die Kategorie .pop – diese Kategorie hat in RadioCategory.tags z. B. ["pop"]
        let filtered = manager.filterStations(for: .pop)
        XCTAssertEqual(filtered.count, 1, "Es sollte genau 1 Station mit dem 'pop'-Tag vorhanden sein.")
        XCTAssertEqual(filtered.first?.id, station1.id, "Die gefilterte Station sollte die Pop Station sein.")
    }

    // Testet, ob bei aktivierter Suche und gesetztem Suchtext nur Stationen zurückgegeben werden, die den Suchtext beinhalten.
    func testApplyFiltersBySearch() {
        let station1 = RadioStation(testID: "1", testName: "Best Pop Station", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")
        let station2 = RadioStation(testID: "2", testName: "Rocking Beats", testTags: "rock", testCountry: "Germany", testCountryCode: "DE")
        let station3 = RadioStation(testID: "3", testName: "Smooth Jazz", testTags: "jazz", testCountry: "Germany", testCountryCode: "DE")

        // Simuliere, dass in der Kategorie .pop alle drei Stationen vorhanden sind.
        manager.stationsByCategory[.pop] = [station1, station2, station3]
        manager.searchActive = true
        manager.searchText = "pop"

        let filtered = manager.applyFilters(to: .pop)
        XCTAssertEqual(filtered.count, 1, "Nur die Station mit 'pop' im Namen oder in den Tags sollte übrig bleiben.")
        XCTAssertEqual(filtered.first?.id, station1.id, "Die gefilterte Station sollte die 'Best Pop Station' sein.")
    }

    // Testet, ob die Filterung nach ausgewähltem Land funktioniert.
    func testApplyFiltersBySelectedCountry() {
        // Erstelle station1 und station2 mit den entsprechenden Länderwerten direkt im Initializer.
        let station1 = RadioStation(
            testID: "1",
            testName: "Station in DE",
            testTags: "pop",
            testCountry: "DE",
            testCountryCode: "DE"
        )
        let station2 = RadioStation(
            testID: "2",
            testName: "Station in US",
            testTags: "pop",
            testCountry: "US",
            testCountryCode: "US"
        )

        manager.stationsByCategory[.pop] = [station1, station2]
        manager.selectedCountry = "US"

        let filtered = manager.applyFilters(to: .pop)
        XCTAssertEqual(filtered.count, 1, "Es sollte nur 1 Station aus den USA übrig bleiben.")
        XCTAssertEqual(filtered.first?.id, station2.id, "Die gefilterte Station sollte die US-Station sein.")
    }

    // Testet, ob die alphabetische Sortierung der gefilterten Stationen korrekt erfolgt.
    func testApplyFiltersAlphabeticalSorting() {
        let station1 = RadioStation(testID: "1", testName: "B Station", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")
        let station2 = RadioStation(testID: "2", testName: "A Station", testTags: "pop", testCountry: "Germany", testCountryCode: "DE")
        manager.stationsByCategory[.pop] = [station1, station2]
        manager.alphabetical = true

        let filtered = manager.applyFilters(to: .pop)
        XCTAssertEqual(filtered.count, 2, "Beide Stationen sollten zurückgegeben werden.")
        XCTAssertEqual(filtered.first?.name, "A Station", "Bei alphabetischer Sortierung sollte 'A Station' an erster Stelle stehen.")
    }
}
