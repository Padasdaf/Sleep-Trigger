//
//  CloudHealth.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-15.
//

import Foundation
import Combine

/// Lightweight iCloud KVS health probe shown in Diagnostics.
@MainActor
final class CloudHealth: ObservableObject {
    static let shared = CloudHealth()

    @Published var isHealthy: Bool = true
    private var timer: Timer?

    /// Begin polling every 30s. Safe to call multiple times.
    func start() {
        // Make sure only one timer exists.
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            // Timer’s closure is @Sendable (non-isolated). Hop back to main.
            guard let self else { return }
            Task { @MainActor in
                self.checkNow()
            }
        }
        if let t = timer {
            t.tolerance = 5
            RunLoop.main.add(t, forMode: .common)
        }

        // Do an immediate probe so UI updates right away.
        checkNow()
    }

    /// Stop polling.
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    /// One-shot health probe.
    func checkNow() {
        // Synchronize returns whether the KVS database could be read/written.
        let ok = NSUbiquitousKeyValueStore.default.synchronize()
        isHealthy = ok
    }

    // Avoid calling actor-isolated methods from deinit in Swift 6; just invalidate directly.
    deinit { timer?.invalidate() }
}
