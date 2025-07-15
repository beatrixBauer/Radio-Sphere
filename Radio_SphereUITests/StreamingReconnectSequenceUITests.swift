//
//  StreamingReconnectSequenceUITests.swift
//  Radio Sphere
//
// Wiederverbindung nach Internetabbruch

import XCTest

extension XCUIElement {
    /// Wartet darauf, dass das Element verschwindet (exists == false)
    func waitForDisappearance(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let exp = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [exp], timeout: timeout) == .completed
    }
}

final class StreamingReconnectSequenceUITests: XCTestCase {
  private var app: XCUIApplication!
  private var startTime: Date!

  override func setUpWithError() throws {
    continueAfterFailure = false

    app = XCUIApplication()
    // Simuliere Netz-Ausfall: nach 30 s offline für 30 s
    app.launchArguments += [
      "-UITestOfflineAfter", "30",
      "-UITestOfflineDuration", "30"
    ]
    app.launch()
    startTime = Date()
  }

  func testStreamPlays30s_ThenOffline30s_ThenPlays30s() throws {
    // 1) Pop-Kategorie wählen
    let pop = app.buttons["category_Pop"]
    XCTAssertTrue(pop.waitForExistence(timeout: 5))
    pop.tap()

    // 2) ersten Sender wählen
    let first = app.cells.element(boundBy: 0)
    XCTAssertTrue(first.waitForExistence(timeout: 10))
    first.tap()

    // 3) 30 s Musik laufen lassen
    sleep(30)

    // 4) Auf Offline-Alert warten
    let alert = app.alerts["Keine Internetverbindung"]
    XCTAssertTrue(alert.waitForExistence(timeout: 60),
                  "Alert muss bei Netz-Ausfall erscheinen")

    // 5) Auf Ende der Offline-Phase + Reconnect warten
    XCTAssertTrue(alert.waitForDisappearance(timeout: 60),
                  "Alert sollte nach 30 s verschwinden und reconnecten")

    // 6) Weitere 30 s Musik laufen lassen
    sleep(30)

    // 7) Prüfen, dass der Stream weiterläuft (Pause-Button wieder da)
    let pause = app.buttons["pauseButton"]
    XCTAssertTrue(pause.waitForExistence(timeout: 5),
                  "Pause-Button sollte nach Reconnect wieder sichtbar sein")
  }

  override func tearDownWithError() throws {
    let end = Date()
    let duration = end.timeIntervalSince(startTime)
    print("""
    - SequenceReconnectUITest START: \(startTime!)
    - SequenceReconnectUITest END:   \(end)
    - Dauer: \(String(format: "%.2f", duration)) s
    """)
    app.terminate()
  }
}
