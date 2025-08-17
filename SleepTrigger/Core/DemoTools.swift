//
//  DemoTools.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-16.
//

import Foundation

#if os(iOS)
import WidgetKit

@MainActor
enum DemoTools {
    /// Fire the same local flow you'd get from the Watch on iOS.
    static func simulateSleepNow() {
        let now = Date()
        HistoryDAO.recordOnset(now)

        // Update widgets (iOS)
        WidgetCenter.shared.reloadAllTimelines()

        // iOS notification + automation pipeline
        NotificationManager.shared.notifySleepDetected()
        SleepEventBridge.shared.handleSleepDetected(now: now)
        SleepEventBridge.shared.publishAppEventIfAvailable()
    }

    /// Seed `n` days of plausible onsets ending yesterday (iOS).
    static func seedSampleHistory(days n: Int = 14) {
        guard n > 0 else { return }
        let cal = Calendar.current
        for i in (1...n).reversed() {
            // Random-ish bedtime between 10:00pm ~ 12:30am
            let base = cal.date(byAdding: .day, value: -i, to: Date())!
            var comps = cal.dateComponents([.year, .month, .day], from: base)
            comps.hour = 22 + Int.random(in: 0...2)
            comps.minute = Int.random(in: 0...1) == 0 ? 10 : 40
            if let when = cal.date(from: comps) {
                HistoryDAO.recordOnset(when)
            }
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
#endif

#if os(macOS)
@MainActor
enum DemoTools {
    /// Mirror a sleep onset on macOS (for menu bar demo flows).
    static func simulateSleepNow() {
        let now = Date()
        HistoryDAO.recordOnset(now)

        // Mirror to iCloud KVS so other devices can see it
        let kv = NSUbiquitousKeyValueStore.default
        kv.set(now.timeIntervalSince1970, forKey: "lastOnset")
        kv.synchronize()

        // Local macOS notification (uses your MacNotificationManager)
        MacNotificationManager.shared.notifyMirroredOnset(now)
    }

    /// Seed `n` days of plausible onsets ending yesterday (macOS).
    static func seedSampleHistory(days n: Int = 14) {
        guard n > 0 else { return }
        let cal = Calendar.current
        for i in (1...n).reversed() {
            let base = cal.date(byAdding: .day, value: -i, to: Date())!
            var comps = cal.dateComponents([.year, .month, .day], from: base)
            comps.hour = 22 + Int.random(in: 0...2)
            comps.minute = Int.random(in: 0...1) == 0 ? 10 : 40
            if let when = cal.date(from: comps) {
                HistoryDAO.recordOnset(when)
            }
        }
    }
}
#endif
