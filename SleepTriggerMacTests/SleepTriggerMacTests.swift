//
//  SleepTriggerMacTests.swift
//  SleepTriggerMacTests
//
//  Created by Daniel Hu on 2025-08-14.
//

import XCTest
@testable import SleepTriggerMac

final class SleepTriggerMacTests: XCTestCase {

    /// Verifies that CloudListener invokes its callback when iCloud KVS
    /// posts `didChangeExternally` with a `lastOnset` value.
    @MainActor
    func testCloudListenerFiresOnKVSChange() {
        let kv = NSUbiquitousKeyValueStore.default
        let exp = expectation(description: "CloudListener callback")

        // Build a listener whose callback fulfills the expectation.
        let listener = CloudListener { _, _ in
            exp.fulfill()
        }

        listener.start()

        // Simulate a mirrored onset arriving via iCloud KVS.
        kv.set(Date().timeIntervalSince1970, forKey: "lastOnset")
        NotificationCenter.default.post(
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: kv
        )

        wait(for: [exp], timeout: 1.0)
        listener.stop()
    }
}
