//
//  SleepScore.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-16.
//

import Foundation

enum SleepScore {
    /// Returns 0..100, or nil if not enough HR data.
    static func fromBPMSeries(_ points: [(Date, Double)]) -> Int? {
        guard points.count >= 5 else { return nil }
        // Use the last ~20–60 samples if you fetched a long window
        let values = points.suffix(120).map { $0.1 } // safe upper bound

        return values.withUnsafeBufferPointer { bp -> Int? in
            guard let base = bp.baseAddress else { return nil }
            let score = ss_sleep_score(base, Int32(bp.count))
            return (score >= 0) ? Int(score) : nil
        }
    }

    static func label(for score: Int) -> String {
        switch score {
        case ..<35:   return "Likely Awake"
        case 35..<65: return "Possibly Asleep"
        default:      return "Likely Asleep"
        }
    }
}
