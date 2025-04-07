import XCTest
@testable import Radio_Sphere

// Falls noch nicht vorhanden, definieren wir einen Convenience-Initializer, um Teststationen schnell zu erzeugen.
extension RadioStation {
    init(testID: String, testName: String, testTags: String = "pop") {
        self.id = testID
        self.name = testName
        self.url = "https://example.com/stream"
        self.country = "DE"
        self.countrycode = "DE"
        self.state = nil
        self.language = "de"
        self.tags = testTags
        self.lastcheckok = 1
        self.imageURL = nil
        self.codec = nil
        self.clickcount = 100
        self.hasExtendedInfo = false
        self.geo_lat = nil
        self.geo_long = nil
    }
}

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
        let station1 = RadioStation(testID: "1", testName: "Pop Station", testTags: "pop, music")
        let station2 = RadioStation(testID: "2", testName: "Rock Station", testTags: "rock, alternative")
        let station3 = RadioStation(testID: "3", testName: "Jazz Station", testTags: "jazz")
        
        // Alle Stationen in manager.allStations bereitstellen
        manager.allStations = [station1, station2, station3]
        // Filtern für die Kategorie .pop – diese Kategorie hat in RadioCategory.tags z. B. ["pop"]
        let filtered = manager.filterStations(for: .pop)
        XCTAssertEqual(filtered.count, 1, "Es sollte genau 1 Station mit dem 'pop'-Tag vorhanden sein.")
        XCTAssertEqual(filtered.first?.id, station1.id, "Die gefilterte Station sollte die Pop Station sein.")
    }
    
    // Testet, ob bei aktivierter Suche und gesetztem Suchtext nur Stationen zurückgegeben werden, die den Suchtext beinhalten.
    func testApplyFiltersBySearch() {
        let station1 = RadioStation(testID: "1", testName: "Best Pop Station", testTags: "pop")
        let station2 = RadioStation(testID: "2", testName: "Rocking Beats", testTags: "rock")
        let station3 = RadioStation(testID: "3", testName: "Smooth Jazz", testTags: "jazz")
        
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
        let station1 = RadioStation(testID: "1", testName: "Station in DE", testTags: "pop")
        let station2 = RadioStation(testID: "2", testName: "Station in US", testTags: "pop")
        // Da der Convenience-Initializer standardmäßig "DE" setzt, modifizieren wir station2 manuell.
        var modStation2 = station2
        modStation2.country = "US"
        modStation2.countrycode = "US"
        
        manager.stationsByCategory[.pop] = [station1, modStation2]
        manager.selectedCountry = "US"
        
        let filtered = manager.applyFilters(to: .pop)
        XCTAssertEqual(filtered.count, 1, "Es sollte nur 1 Station aus den USA übrig bleiben.")
        XCTAssertEqual(filtered.first?.id, modStation2.id, "Die gefilterte Station sollte die US-Station sein.")
    }
    
    // Testet, ob die alphabetische Sortierung der gefilterten Stationen korrekt erfolgt.
    func testApplyFiltersAlphabeticalSorting() {
        let station1 = RadioStation(testID: "1", testName: "B Station", testTags: "pop")
        let station2 = RadioStation(testID: "2", testName: "A Station", testTags: "pop")
        manager.stationsByCategory[.pop] = [station1, station2]
        manager.alphabetical = true
        
        let filtered = manager.applyFilters(to: .pop)
        XCTAssertEqual(filtered.count, 2, "Beide Stationen sollten zurückgegeben werden.")
        XCTAssertEqual(filtered.first?.name, "A Station", "Bei alphabetischer Sortierung sollte 'A Station' an erster Stelle stehen.")
    }
}
