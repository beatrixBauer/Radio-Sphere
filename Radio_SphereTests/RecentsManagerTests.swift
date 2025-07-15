//
//  RecentsManagerTests.swift
//  Radio_Sphere
//
// Test Verlaufsverwaltung

import XCTest
@testable import Radio_Sphere

final class RecentsManagerTests: XCTestCase {

    /// Merkt sich alle erfolgreich durchgelaufenen Test-Cases dieser Klasse
    private static var passedTests: [String] = []

    // MARK: - pro Test-Case

    override func setUp() {
        super.setUp()
        // Sicherstellen, dass wir stets mit einer leeren Liste starten
        RecentsManager.shared.clearRecents()
    }

    override func tearDown() {
        defer { super.tearDown() }
        // Wenn dieser Test fehlerfrei war, merken wir uns seinen Namen
        if let run = testRun,
           run.failureCount == 0,
           run.unexpectedExceptionCount == 0 {
            Self.passedTests.append(name)
        }
    }

    // MARK: - einmal nach allen Tests dieser Klasse

    override class func tearDown() {
        defer { super.tearDown() }
        print("\nAlle Tests bestanden (\(passedTests.count) Tests):")
        for testName in passedTests {
            print(" • \(testName)")
        }
    }

    // MARK: - Tests

    func testAddStationAtBeginning() {
        let manager = RecentsManager.shared

        // Station 1 hinzufügen
        manager.addRecentStation("station1")
        XCTAssertEqual(manager.recentStationIDs, ["station1"],
                       "Nach Hinzufügen von station1 muss die Liste genau [\"station1\"] sein.")

        // Station 2 hinzufügen → station2 muss an den Anfang
        manager.addRecentStation("station2")
        XCTAssertEqual(manager.recentStationIDs.first, "station2",
                       "Nach Hinzufügen von station2 muss station2 an erster Stelle stehen.")
        XCTAssertEqual(manager.recentStationIDs.dropFirst(), ["station1"],
                       "station1 muss nun an zweiter Stelle stehen.")
    }

    func testMaxTwentyStations() {
        let manager = RecentsManager.shared

        // 21 verschiedene Stationen hinzufügen
        for i in 1...21 {
            manager.addRecentStation("station\(i)")
        }

        // Es dürfen nur 20 Einträge existieren
        XCTAssertEqual(manager.recentStationIDs.count, 20,
                       "Die Liste darf nicht mehr als 20 Einträge enthalten.")

        // station21 muss an erster Stelle stehen
        XCTAssertEqual(manager.recentStationIDs.first, "station21",
                       "Neu hinzugefügte station21 muss an erster Stelle stehen.")

        // station1 (die älteste) darf nicht mehr in der Liste sein
        XCTAssertFalse(manager.recentStationIDs.contains("station1"),
                      "station1 muss als ältester Eintrag entfernt worden sein.")

        // station2 muss nun der letzte Eintrag sein
        XCTAssertEqual(manager.recentStationIDs.last, "station2",
                       "Nach Entfernen von station1 ist station2 der älteste verbleibende und damit letzter Eintrag.")
    }
}





