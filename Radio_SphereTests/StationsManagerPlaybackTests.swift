//
//  StationsManagerPlaybackTests.swift
//  Radio_SphereTests
//
//  Unit-Tests für StationsManager: Play, Pause, Stop, Next, Previous
//  + kompakte Konsolen-Summary via TestSummaryObserver
//

@testable import Radio_Sphere
import XCTest

// MARK: - Testklasse
final class StationsManagerPlaybackTests: XCTestCase {

    // Observer beim ersten Zugriff auf die Klasse initialisieren
    private static let summaryObserverBootstrap: Void = {
        _ = TestSummaryObserver.shared          // registriert sich beim XCTestObservationCenter
    }()

    // Manager & Stub-Stationen
    private var manager: StationsManager!
    private var s1: RadioStation!
    private var s2: RadioStation!
    private var s3: RadioStation!

    // MARK: - Setup / Teardown
    override func setUpWithError() throws {
        // Sicherstellen, dass der Observer aktiv ist
        _ = StationsManagerPlaybackTests.summaryObserverBootstrap

        manager = StationsManager.shared
        resetManager()

        // Drei Stub-Stationen anlegen
        s1 = .init(name: "Unit-Rock 1")
        s2 = .init(name: "Unit-Rock 2")
        s3 = .init(name: "Unit-Rock 3")

        manager.currentNavigationList = [s1, s2, s3]
        manager.currentIndex          = 0
    }

    override func tearDownWithError() throws { resetManager() }

    private func resetManager() {
        manager.stopPlayback()                 // setzt alle Flags zurück
        manager.currentNavigationList = []
        manager.currentIndex          = nil
        manager.currentStation        = nil
        manager.userDidPause          = false
        manager.isMiniPlayerVisible   = false
    }

    // MARK: - Tests

    func testPlaySetsCurrentStation() {
        manager.set(station: s1)
        XCTAssertEqual(manager.currentStation?.id, s1.id)
        XCTAssertFalse(manager.userDidPause)
    }

    func testPauseSetsUserDidPause() {
        manager.set(station: s1)
        manager.pausePlayback()
        XCTAssertTrue(manager.userDidPause)
    }

    func testStopClearsMiniPlayer() {
        manager.set(station: s1)
        manager.isMiniPlayerVisible = true
        manager.stopPlayback()
        XCTAssertFalse(manager.isMiniPlayerVisible)
        XCTAssertNil(manager.currentArtworkURL)
    }

    func testSetNextAdvancesToNextStation() {
        manager.set(station: s1)
        manager.setNext()
        XCTAssertEqual(manager.currentStation?.id, s2.id)
        XCTAssertEqual(manager.currentIndex, 1)
    }

    func testSetPreviousMovesBack() {
        manager.set(station: s1)
        manager.setNext()
        manager.setPrevious()
        XCTAssertEqual(manager.currentStation?.id, s1.id)
        XCTAssertEqual(manager.currentIndex, 0)
    }
}

// MARK: - Convenience-Initialiser für RadioStation (nur im Test-Target)
private extension RadioStation {
    init(testID: String = UUID().uuidString,
         name: String,
         url: String = "https://example.com/stream.mp3") {
        self.id              = testID
        self.name            = name
        self.url             = url
        self.country         = "DE"
        self.countrycode     = "DE"
        self.state           = nil
        self.language        = "German"
        self.tags            = nil
        self.lastcheckok     = 1
        self.imageURL        = nil
        self.codec           = nil
        self.clickcount      = 0
        self.hasExtendedInfo = false
        self.geo_lat         = nil
        self.geo_long        = nil
    }
}
