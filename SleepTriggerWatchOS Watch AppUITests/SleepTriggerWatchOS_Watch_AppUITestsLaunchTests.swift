//
//  SleepTriggerWatchOS_Watch_AppUITestsLaunchTests.swift
//  SleepTriggerWatchOS Watch AppUITests
//
//  Created by Daniel Hu on 2025-08-12.
//

import XCTest

final class SleepTriggerWatchOS_Watch_AppUITestsLaunchTests: XCTestCase {
    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
