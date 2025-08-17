//
//  DeviceMotionMonitor.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation
import CoreMotion
import Combine

/// Calculates a robust "stillness score" using Device Motion (gravity-removed userAcceleration).
/// - Sampling: 10 Hz
/// - A short window (~5s) computes variance; each window is "still" if variance < threshold.
/// - A hysteresis buffer (~15 windows ≈ 75s) yields a stillness score in [0, 1].
final class DeviceMotionMonitor: ObservableObject {
    private let manager = CMMotionManager()
    private let queue = OperationQueue()

    // Per-sample buffer for current short window
    private var window: [Double] = []
    private let samplesPerWindow = 50          // 5s @ 10 Hz
    private let varianceThreshold = 0.0008     // tuned for userAcceleration magnitude

    // Hysteresis over recent windows
    private var recentWindows: [Bool] = []
    private let hysteresisWindows = 15         // ~75s total

    @Published private(set) var stillnessScore: Double = 0.0 // 0...1 (fraction of still windows)
    @Published private(set) var isStillNow: Bool = false     // instantaneous window label

    func start() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 10.0
        manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: queue) { [weak self] dm, _ in
            guard let self, let dm else { return }
            let ua = dm.userAcceleration
            // magnitude of user acceleration
            let mag = sqrt(ua.x*ua.x + ua.y*ua.y + ua.z*ua.z)
            self.window.append(mag)

            if self.window.count >= self.samplesPerWindow {
                // Compute variance of current window
                let mean = self.window.reduce(0,+) / Double(self.window.count)
                let varSum = self.window.reduce(0) { $0 + pow($1 - mean, 2) }
                let variance = varSum / Double(self.window.count)
                let still = variance < self.varianceThreshold

                // Slide window + update hysteresis
                self.window.removeAll(keepingCapacity: true)
                self.recentWindows.append(still)
                if self.recentWindows.count > self.hysteresisWindows {
                    self.recentWindows.removeFirst()
                }

                let score = Double(self.recentWindows.filter { $0 }.count) / Double(max(1, self.recentWindows.count))

                DispatchQueue.main.async {
                    self.isStillNow = still
                    self.stillnessScore = score
                }
            }
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
        window.removeAll()
        recentWindows.removeAll()
        DispatchQueue.main.async {
            self.isStillNow = false
            self.stillnessScore = 0
        }
    }
}
