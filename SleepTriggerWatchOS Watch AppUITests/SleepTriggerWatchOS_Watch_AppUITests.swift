//
//  SleepTriggerWatchOS_Watch_AppUITests.swift
//  SleepTriggerWatchOS Watch AppUITests
//
//  Created by Daniel Hu on 2025-08-12.
//

import XCTest

final class SleepTriggerWatchOS_Watch_AppUITests: XCTestCase {
    func testMainTitleAppears() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["SleepTrigger"].waitForExistence(timeout: 5))
    }
}
