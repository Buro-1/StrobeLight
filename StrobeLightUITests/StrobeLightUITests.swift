//
//  StrobeLightUITests.swift
//  StrobeLightUITests
//
//  Created by Jesse Born on 10.05.23.
//

import XCTest

final class StrobeLightUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        snapshot("0-Home")
        print(XCUIApplication().debugDescription)
        let powerknob = app.images.element(matching: .image, identifier: "Knob")
        let onLabel = app.staticTexts["25 Hz"]
        let autoLabel = app.staticTexts["Music Mode"]
        
        powerknob.press(forDuration: 0.25, thenDragTo: onLabel, withVelocity: .default, thenHoldForDuration: 0.25)
        snapshot("1-On")
        powerknob.press(forDuration: 0.25, thenDragTo: autoLabel, withVelocity: .default, thenHoldForDuration: 0.25)
        
        for i in 0..<(app.alerts.count) {
            app.alerts.allElementsBoundByIndex[i].scrollViews.otherElements.buttons["OK"].tap()
        }
        snapshot("2-Auto")
        
        

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
