import XCTest
@testable import Radio_Sphere

final class RecentsManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Sicherstellen, dass wir mit einer leeren Liste starten
        RecentsManager.shared.clearRecents()
    }

    func testAddRecentStation() {
        let manager = RecentsManager.shared

        // Füge einen Sender hinzu und überprüfe, ob er an erster Stelle steht
        manager.addRecentStation("station1")
        XCTAssertEqual(manager.recentStationIDs.first, "station1", "Der Sender sollte an erster Stelle stehen.")

        // Füge denselben Sender erneut hinzu und erwarte, dass keine Duplikate entstehen
        manager.addRecentStation("station1")
        XCTAssertEqual(manager.recentStationIDs.count, 1, "Es dürfen keine doppelten Einträge entstehen.")

        // Füge mehrere Sender hinzu und teste, ob das Maximum (20) eingehalten wird
        for i in 2...25 {
            manager.addRecentStation("station\(i)")
        }
        XCTAssertEqual(manager.recentStationIDs.count, 20, "Die Liste darf nicht mehr als 20 Einträge enthalten.")
    }

    func testClearRecents() {
        let manager = RecentsManager.shared
        manager.addRecentStation("station1")
        manager.addRecentStation("station2")
        XCTAssertFalse(manager.recentStationIDs.isEmpty, "Die Liste sollte Einträge enthalten.")
        
        manager.clearRecents()
        XCTAssertTrue(manager.recentStationIDs.isEmpty, "Die Liste sollte geleert worden sein.")
    }
}
