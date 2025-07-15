//
//  LaunchPerformanceTests.swift
//  Radio Sphere
//
// Test der APP-Startzeit (Neustart und aus dem Hintergrund)


import XCTest

final class LaunchPerformanceTests: XCTestCase {
    
    // Observer beim ersten Zugriff auf die Klasse initialisieren
    private static let summaryObserverBootstrap: Void = {
        _ = TestSummaryObserver.shared          // registriert sich beim XCTestObservationCenter
    }()

    override func setUp() {
        _ = LaunchPerformanceTests.summaryObserverBootstrap
        continueAfterFailure = false
    }

    // Cold-Start
    func testColdLaunch() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()          // wird von XCTest nach jeder Iteration gekillt
        }
    }

    // Warm-Start
    func testWarmLaunch() {
        let app = XCUIApplication(bundleIdentifier: "com.beatrixbauer.Radio-Sphere")
        app.launch()                           // einmalig kalt starten

        measure(metrics: [XCTClockMetric()]) { // misst Dauer von activate → home
            app.activate()                     // Warm-Resume
            XCUIDevice.shared.press(.home)     // zurück in den Hintergrund
        }
    }
}


