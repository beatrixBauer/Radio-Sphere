//
//  MainViewUITests.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 06.04.25.
//


import XCTest

class MainViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        // Launch-Argument, das in deinem App-Code abgefragt wird, um den Offline-Modus zu simulieren.
        app.launchArguments.append("UITest_NoInternet")
        app.launch()
    }
    
    override func tearDown() {
        app.terminate()
        super.tearDown()
    }
    
    func testNoInternetAlertAppears() {
        // Wir erwarten, dass ein Alert mit dem Titel "Keine Internetverbindung" erscheint.
        let alert = app.alerts["Keine Internetverbindung"]
        let exists = NSPredicate(format: "exists == true")
        
        expectation(for: exists, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertTrue(alert.exists, "Der Alert 'Keine Internetverbindung' sollte angezeigt werden.")
    }
}
