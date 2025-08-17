//
//  SleepTriggerUITests.swift
//  SleepTriggerUITests
//
//  Created by Daniel Hu on 2025-08-12.
//

import XCTest

final class SleepTriggerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    @MainActor
    func testTabsExistAndNavigate() throws {
        let app = XCUIApplication()
        app.launch()

        // Tab bar items from your ContentView
        let home = app.tabBars.buttons["Home"]
        let automations = app.tabBars.buttons["Automations"]
        let history = app.tabBars.buttons["History"]
        let diagnostics = app.tabBars.buttons["Diagnostics"]

        XCTAssertTrue(home.waitForExistence(timeout: 5))
        XCTAssertTrue(automations.exists)
        XCTAssertTrue(history.exists)
        XCTAssertTrue(diagnostics.exists)

        diagnostics.tap()
        XCTAssertTrue(app.staticTexts["Connectivity"].waitForExistence(timeout: 3))

        history.tap()
        XCTAssertTrue(app.staticTexts["Recent"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
