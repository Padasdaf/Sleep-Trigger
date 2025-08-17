//
//  SleepTriggerMacUITestsLaunchTests.swift
//  SleepTriggerMacUITests
//
//  Created by Daniel Hu on 2025-08-14.
//

import XCTest

final class SleepTriggerMacUITestsLaunchTests: XCTestCase {
    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
