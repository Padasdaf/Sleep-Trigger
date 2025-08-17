//
//  CloudListener.swift
//  SleepTriggerMac
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation

/// Listens for mirrored sleep-onset timestamps arriving via iCloud KVS.
/// You control lifecycle explicitly with `start()` and `stop()`.
final class CloudListener {

    typealias OnOnset = (_ date: Date, _ source: String) -> Void

    private let onOnset: OnOnset
    private var token: NSObjectProtocol?
    private var isStarted = false

    init(onOnset: @escaping OnOnset) {
        self.onOnset = onOnset
    }

    /// Begin listening (idempotent).
    func start() {
        guard !isStarted else { return }
        isStarted = true

        let store = NSUbiquitousKeyValueStore.default
        store.synchronize()

        // Use a fresh store inside the closure to avoid capturing non-Sendable values.
        token = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            if let t = NSUbiquitousKeyValueStore.default.object(forKey: "lastOnset") as? Double {
                self.onOnset(Date(timeIntervalSince1970: t), "iCloud")
            }
        }
    }

    /// Stop listening (idempotent).
    func stop() {
        if let token {
            NotificationCenter.default.removeObserver(token)
            self.token = nil
        }
        isStarted = false
    }

    deinit { stop() }
}
