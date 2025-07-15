//
//  StreamingEndToEndUITests.swift
//  Radio Sphere
//
// 2h Dauerstream

import XCTest

final class StreamingEndToEndUITests: XCTestCase {
    private var app: XCUIApplication!
    private var startTime: Date!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        // 1) App starten
        app.launch()

        // 2) Startzeit protokollieren
        startTime = Date()
    }

    func test2HourContinuousStream_PopCategory() throws {

        // 3) ContentView: Kategorie „Pop“ auswählen
        let popCategory = app.buttons["category_Pop"]
        XCTAssertTrue(popCategory.waitForExistence(timeout: 5), "Pop-Kategorie sollte sichtbar sein")
        popCategory.tap()

        // 4) StationsView: ersten Sender anwählen
        let firstStationCell = app.cells.element(boundBy: 0)
         XCTAssertTrue(firstStationCell.waitForExistence(timeout: 10), "Erste Sender-Zeile sollte in der StationsView erscheinen")
         firstStationCell.tap()

        // 5) 2 Stunden warten (7200 s)
        let expectation = expectation(description: "2 h Dauerstream")
        DispatchQueue.main.asyncAfter(deadline: .now() + 7200) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 7200 + 5)

        // Optional: Stream beenden (z.B. per Button oder direkt im StationsManager)
        // app.buttons["stopButton"].tap()
    }

    override func tearDownWithError() throws {
        // 6) Endzeit protokollieren
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        // 6) Zusammenfassung erzeugen
        let summary = """
        - StreamingEndToEndUITest
        START: \(startTime!)
        END:   \(endTime)
        Dauer: \(String(format: "%.2f", duration/3600)) h
        """
        let attachment = XCTAttachment(string: summary)
        attachment.name = "Streaming_Test_Summary"
        attachment.lifetime = .keepAlways
        add(attachment)

        // 7) Crashes werden von XCTest automatisch als Test-Failure gemeldet.
        app.terminate()
    }
}
