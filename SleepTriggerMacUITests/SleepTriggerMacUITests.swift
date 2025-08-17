//
//  SleepTriggerMacUITests.swift
//  SleepTriggerMacUITests
//
//  Created by Daniel Hu on 2025-08-14.
//

import XCTest

final class SleepTriggerMacUITests: XCTestCase {
    func testAppLaunchesAndMenuBarExists() {
        let app = XCUIApplication()
        app.launch()

        // Either a window is present, or (for pure menu-bar style) the menu bar exists.
        XCTAssertTrue(app.windows.element(boundBy: 0).exists || app.menuBars.element.exists)
    }
}
