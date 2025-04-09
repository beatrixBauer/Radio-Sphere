//
//  SplashViewUITests.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 06.05.25.
//


import XCTest

class SplashViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        // Ein Launch-Argument, um den SplashScreen in einem Test-Modus länger anzuzeigen.
        app.launchArguments.append("UITest_SplashView")
        app.launch()
    }
    
    override func tearDown() {
        app.terminate()
        super.tearDown()
    }
    
    func testSplashViewDisplaysAppName() {
        // Wir warten darauf, dass der Text "Radio Sphere" (der Name der App) sichtbar wird.
        let appNameLabel = app.staticTexts["Radio Sphere"]
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: appNameLabel, handler: nil)
        waitForExpectations(timeout: 6, handler: nil)
        XCTAssertTrue(appNameLabel.exists, "Der App-Name 'Radio Sphere' sollte sichtbar sein.")
    }
}
