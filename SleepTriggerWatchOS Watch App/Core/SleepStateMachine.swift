//
//  SleepStateMachine.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation

enum SleepState: Equatable {
    case awake
    case drowsy(since: Date)
    case asleep(at: Date)
}

/// Tiny state machine with hysteresis.
final class SleepStateMachine {

    // Tunables
    var dropThreshold: Double = -0.12        // -12% vs baseline (negative = below)
    var minDrowsySeconds: TimeInterval = 180 // 3 minutes sustained
    var minStillScore: Double = 0.80         // 80% of recent windows "still"
    var requireNegativeSlope = true          // HR trending downward

    private(set) var state: SleepState = .awake

    /// Feed new measurements.
    /// - Parameters:
    ///   - dropFraction: (latest - baseline) / baseline  (negative when lower)
    ///   - stillness: 0...1 (fraction of "still" windows recently)
    ///   - slope: bpm/sec (negative = falling)
    func ingest(dropFraction: Double?,
                stillness: Double,
                slope: Double?,
                now: Date = .now) -> SleepState {

        switch state {
        case .awake:
            // Gate into drowsy when prelim conditions begin
            if let d = dropFraction,
               d <= dropThreshold * 0.5,      // start noticing earlier
               stillness >= minStillScore * 0.7 {
                state = .drowsy(since: now)
            }

        case .drowsy(let since):
            let sustained = now.timeIntervalSince(since) >= minDrowsySeconds
            let hrIsLow = (dropFraction ?? 0) <= dropThreshold
            let slopeOK = (requireNegativeSlope ? ((slope ?? 0) < 0) : true)
            let stillOK = stillness >= minStillScore

            if hrIsLow && stillOK && slopeOK && sustained {
                state = .asleep(at: now)
            }

            // If motion spikes or HR rebounds, go back to awake
            if stillness < minStillScore * 0.5 || (dropFraction ?? 0) > dropThreshold * 0.25 {
                state = .awake
            }

        case .asleep:
            break
        }

        return state
    }

    func reset() { state = .awake }
}
