//
//  StationsManagerSleepTimerTests.swift
//  Radio Sphere
//
// Test der Sleeptimer-Logik

import XCTest
@testable import Radio_Sphere

final class StationsManagerSleepTimerTests: XCTestCase {
    // Observer beim ersten Zugriff auf die Klasse initialisieren
    private static let summaryObserverBootstrap: Void = {
        _ = TestSummaryObserver.shared          // registriert sich beim XCTestObservationCenter
    }()

    private var manager: StationsManager!

    override func setUpWithError() throws {
        _ = StationsManagerSleepTimerTests.summaryObserverBootstrap
        manager = StationsManager.shared
        // sauberen Zustand herstellen
        manager.stopSleepTimer()
        manager.userDidPause = false
        manager.isMiniPlayerVisible = false
    }

    override func tearDownWithError() throws {
        manager.stopSleepTimer()
        manager = nil
    }

    func testStartSleepTimerInitializes() {
        manager.startSleepTimer(minutes: 1)
        XCTAssertTrue(manager.isSleepTimerActive, "Timer sollte aktiv sein nach startSleepTimer")
        XCTAssertEqual(manager.sleepTimerRemainingTime, 60, "RemainingTime sollte 60 Sekunden entsprechen")
    }

    func testSleepTimerCountsDownAfterOneSecond() {
        manager.startSleepTimer(minutes: 1)
        let exp = expectation(description: "Warte auf ersten Tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            XCTAssertEqual(self.manager.sleepTimerRemainingTime, 59,
                           "RemainingTime sollte nach 1 s um 1 gesunken sein")
            exp.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testStopSleepTimerResetsState() {
        manager.startSleepTimer(minutes: 1)
        XCTAssertTrue(manager.isSleepTimerActive)
        manager.stopSleepTimer()
        XCTAssertFalse(manager.isSleepTimerActive, "Timer sollte inaktiv sein nach stopSleepTimer")
        XCTAssertNil(manager.sleepTimerRemainingTime, "RemainingTime sollte nil sein nach stopSleepTimer")
    }

    func testSleepTimerTriggersPauseOnFinish() {
        // 0 Minuten → Timer läuft, feuert nach 1 s und pausiert
        manager.startSleepTimer(minutes: 0)
        let exp = expectation(description: "Warte auf Timer-Ende")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            XCTAssertTrue(self.manager.userDidPause,
                          "pausePlayback() sollte userDidPause = true setzen")
            XCTAssertFalse(self.manager.isSleepTimerActive,
                           "Timer sollte inaktiv sein nach Ablauf")
            exp.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
}

