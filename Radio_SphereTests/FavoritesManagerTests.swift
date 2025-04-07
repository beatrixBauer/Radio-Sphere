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
        let testStation = RadioStation(
            id: "station1",
            name: "Test Station",
            url: "https://example.com",
            country: "DE",
            countrycode: "DE",
            state: nil,
            language: "de",
            tags: "pop",
            lastcheckok: 1,
            imageURL: nil,
            codec: nil,
            clickcount: 100,
            geo_lat: nil,
            geo_long: nil
        )

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
        let testStation = RadioStation(
            id: "station1",
            name: "Test Station",
            url: "https://example.com",
            country: "DE",
            countrycode: "DE",
            state: nil,
            language: "de",
            tags: "pop",
            lastcheckok: 1,
            imageURL: nil,
            codec: nil,
            clickcount: 100,
            geo_lat: nil,
            geo_long: nil
        )

        XCTAssertFalse(manager.isFavorite(station: testStation), "Die Station sollte noch nicht favorisiert sein.")
        manager.addFavorite(station: testStation)
        XCTAssertTrue(manager.isFavorite(station: testStation), "Die Station sollte jetzt favorisiert sein.")
    }
}
