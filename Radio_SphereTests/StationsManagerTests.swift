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
        let station1 = RadioStation(
            id: "1",
            name: "Station A",
            url: "http://example.com",
            country: "DE",
            countrycode: "DE",
            state: nil,
            language: "de",
            tags: "pop",
            lastcheckok: 1,
            imageURL: nil,
            codec: nil,
            clickcount: 100,
            geo_lat: 0.0,
            geo_long: 0.0
        )
        // Eine Station mit gleichem Namen, aber anderer ID
        let station2 = RadioStation(
            id: "2",
            name: "Station A",
            url: "http://example.org",
            country: "DE",
            countrycode: "DE",
            state: nil,
            language: "de",
            tags: "rock",
            lastcheckok: 1,
            imageURL: nil,
            codec: nil,
            clickcount: 200,
            geo_lat: 0.0,
            geo_long: 0.0
        )
        let station3 = RadioStation(
            id: "3",
            name: "Station B",
            url: "http://example.net",
            country: "DE",
            countrycode: "DE",
            state: nil,
            language: "de",
            tags: "jazz",
            lastcheckok: 1,
            imageURL: nil,
            codec: nil,
            clickcount: 150,
            geo_lat: 0.0,
            geo_long: 0.0
        )
        let stations = [station1, station2, station3]
        let uniqueStations = manager.filterUniqueStationsByName(stations)
        XCTAssertEqual(uniqueStations.count, 2, "Es sollten 2 eindeutige Stationen vorhanden sein.")
    }

    func testApplyFiltersWithSearch() {
        // Setze eine Testkategorie und Stationen
        let category = RadioCategory.pop
        let stationPop = RadioStation(
            id: "1",
            name: "Pop Station",
            url: "http://example.com",
            country: "DE",
            countrycode: "DE",
            state: nil,
            language: "de",
            tags: "pop",
            lastcheckok: 1,
            imageURL: nil,
            codec: nil,
            clickcount: 100,
            geo_lat: 0.0,
            geo_long: 0.0
        )
        let stationRock = RadioStation(
            id: "2",
            name: "Rock Station",
            url: "http://example.org",
            country: "US",
            countrycode: "US",
            state: nil,
            language: "en",
            tags: "rock",
            lastcheckok: 1,
            imageURL: nil,
            codec: nil,
            clickcount: 200,
            geo_lat: 0.0,
            geo_long: 0.0
        )
        manager.stationsByCategory[category] = [stationPop, stationRock]
        manager.searchActive = true
        manager.searchText = "pop"
        
        let filtered = manager.applyFilters(to: category)
        XCTAssertEqual(filtered.count, 1, "Es sollten nur 1 Station nach Filterung übrig bleiben.")
        XCTAssertEqual(filtered.first?.id, stationPop.id, "Die gefilterte Station sollte die Pop Station sein.")
    }
}
