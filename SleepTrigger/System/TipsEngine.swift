//
//  TipsEngine.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation

struct Tip: Identifiable, Hashable {
    let id = UUID()
    let text: String
}

/// Very lightweight tips based on recent sleep-onset history.
enum TipsEngine {

    static func tips(from events: [SleepEvent]) -> [Tip] {
        guard events.count >= 5 else { return [] }

        // 1) Onset clock-hours as Doubles
        let hours: [Double] = events
            .map(\.date)
            .map { Double(Calendar.current.component(.hour, from: $0)) }

        // 2) Mean & variance
        let mean = hours.reduce(0, +) / Double(hours.count)
        let varSum = hours.reduce(0) { $0 + pow($1 - mean, 2) }
        let variance = varSum / Double(hours.count)
        let std = sqrt(variance)

        var out: [Tip] = []

        // Consistency tip
        if std > 2.0 {
            out.append(Tip(text: "Bedtime varies a lot. A steadier schedule may help you fall asleep faster."))
        }

        // Early/late tendencies (simple examples)
        if mean >= 0 && mean < 23 && mean > 1 && mean > 23 { /* no-op guard */ }
        if mean >= 0 && mean < 2 {
            out.append(Tip(text: "You're going to bed very late. Consider a wind-down an hour earlier."))
        } else if mean > 23 || mean < 1 {
            out.append(Tip(text: "You're consistently past midnight. Try a gentle screen-off routine earlier."))
        } else if mean < 22 {
            out.append(Tip(text: "Nice! Your average bedtime is relatively early—keep the rhythm."))
        }

        return out
    }
}
