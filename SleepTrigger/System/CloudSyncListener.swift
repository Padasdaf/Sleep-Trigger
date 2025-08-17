//
//  CloudSyncListener.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation
import os.log

private let detectLog = Logger(subsystem: "com.danielhu.SleepTrigger", category: "Detect")

/// Listens for mirrored sleep-onset timestamps arriving via iCloud KVS
/// and reuses the bridge to act locally.
final class CloudSyncListener {

    static let shared = CloudSyncListener()
    private init() {}

    private var observer: NSObjectProtocol?

    /// Begin listening (idempotent).
    func start() {
        guard observer == nil else { return }

        let store = NSUbiquitousKeyValueStore.default
        store.synchronize()

        // Avoid capturing non-Sendable values; hop back to main explicitly.
        observer = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store,
            queue: .main
        ) { _ in
            // Re-fetch inside the closure to avoid capturing `store`.
            guard let t = NSUbiquitousKeyValueStore.default.object(forKey: "lastOnset") as? Double else { return }
            let date = Date(timeIntervalSince1970: t)
            detectLog.debug("KVS mirror received onset \(date, privacy: .public)")

            Task { @MainActor in
                SleepEventBridge.shared.handleSleepDetected(now: date)
            }
        }
    }

    func stop() {
        if let obs = observer {
            NotificationCenter.default.removeObserver(obs)
            observer = nil
        }
    }
}
