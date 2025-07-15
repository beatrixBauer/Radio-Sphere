//
//  StreamingUITests.swift
//  Radio Sphere
//
// obsolet Test 2h Dauerstream
//

import XCTest

final class StreamingUITests: XCTestCase {
  private var app: XCUIApplication!
  private var startTime: Date!

  override func setUpWithError() throws {
    continueAfterFailure = false

    app = XCUIApplication()
    // sorgt dafür, dass Radio_SphereApp die PlayerView direkt lädt und set(station:) aufruft
    app.launchArguments += ["-UITestMode", "-startPlayerView"]
    startTime = Date()

    app.launch()
  }

  func testContinuous2HourStream() throws {
    // Der Stream startet automatisch in set(station:), kein Play-Tap nötig.
    // Einfach 2 Stunden (7200 s) warten:
    let waitSeconds: TimeInterval = 7200
    let expectation = self.expectation(description: "2-hour continuous streaming")
    // Wir feuern die Expectation erst nach waitSeconds ab:
    DispatchQueue.main.asyncAfter(deadline: .now() + waitSeconds) {
      expectation.fulfill()
    }
    // Timeout ist gleich der Wartezeit
    wait(for: [expectation], timeout: waitSeconds + 5)

    // Wenn zwischendrin ein Crash passiert, bricht der Test ab.
    // Hier kommen wir nur an, wenn alles 2 h lief.
  }

  override func tearDownWithError() throws {
    // Ende-Messung
    let endTime = Date()
    let duration = endTime.timeIntervalSince(startTime)

    // Zusammenfassung als XCTAttachment
    let summary = """
    - StreamingUITest START: \(startTime!)
    - StreamingUITest END:   \(endTime)
    - Duration: \(String(format: "%.2f", duration/3600)) h
    """
    let attachment = XCTAttachment(string: summary)
    attachment.name = "Streaming_Test_Summary"
    attachment.lifetime = .keepAlways
    add(attachment)

    // Optionale Aufräum-Aktion: Stream stoppen
    app.terminate()
  }
}
