//
//  SleepEventBridge.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation
import UIKit
import WidgetKit

/// Orchestrates "what to do" once sleep is detected.
@MainActor
final class SleepEventBridge {
    static let shared = SleepEventBridge()
    private init() {}

    private var pendingWorkItem: DispatchWorkItem?

    /// Main entry called by PhoneConnectivityManager when watch reports sleep.
    func handleSleepDetected(now: Date = Date()) {
        let s = AppSettings.shared

        // Cancel-once gate from notification action
        if s.cancelNextEvent {
            s.cancelNextEvent = false
            return
        }

        // Armed gate
        guard s.armed else { return }

        // Time-of-day gate
        if s.gatingEnabled, !withinHours(start: s.gateStartHour, end: s.gateEndHour, now: now) {
            return
        }

        // Post-sleep lockout
        if let last = UserDefaults.standard.object(forKey: "lastAutomationRun") as? Date {
            let mins = now.timeIntervalSince(last) / 60.0
            if mins < Double(s.postAsleepLockoutMinutes) { return }
        }

        // --- persist + mirror + smart alarm + widgets (actor-safe) ---
        Task {
            await HistoryStore.shared.append(date: now, bpm: nil) // persist locally
            // The following aren’t actors, so no await:
            CloudSync.shared.pushOnset(now)                        // mirror to iCloud KVS
            SmartAlarmManager.shared.scheduleIfEnabled(after: now)
            await MainActor.run { WidgetCenter.shared.reloadAllTimelines() }
        }
        // -------------------------------------------------------------

        // Pick a shortcut via rule engine (or fallbacks)
        let chosen = RuleEngine.shared.routeShortcut(now: now) ?? s.shortcutName

        // Optional “hold” so the user can act on the notification first
        scheduleHold(seconds: s.holdSecondsBeforeRun) {
            self.runShortcut(named: chosen)
        }
    }

    /// Called from notification action "Run Alternate".
    func runAlternateNow() {
        let alt = AppSettings.shared.alternateShortcutName
        guard !alt.isEmpty else { return }
        runShortcut(named: alt)
    }

    // Public “snooze” API used by NotificationManager
    func scheduleHold(seconds: Int) {
        scheduleHoldAfter(seconds: seconds) {
            let name = RuleEngine.shared.routeShortcut() ?? AppSettings.shared.shortcutName
            self.runShortcut(named: name)
        }
    }

    // MARK: - Private helpers

    private func scheduleHold(seconds: Int, run: @escaping () -> Void) {
        scheduleHoldAfter(seconds: seconds, run)
    }

    private func scheduleHoldAfter(seconds: Int, _ run: @escaping () -> Void) {
        pendingWorkItem?.cancel()
        let wi = DispatchWorkItem(block: run)
        pendingWorkItem = wi
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(max(0, seconds)), execute: wi)
    }

    private func runShortcut(named: String) {
        guard !named.isEmpty else { return }
        let encoded = named.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? named
        let urlString = "shortcuts://x-callback-url/run-shortcut?name=\(encoded)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
            UserDefaults.standard.set(Date(), forKey: "lastAutomationRun")
        }
    }

    private func withinHours(start: Int, end: Int, now: Date) -> Bool {
        let h = Calendar.current.component(.hour, from: now) // 0..23
        if start <= end { return (start...end).contains(h) }
        return h >= start || h <= end // overnight wrap
    }

    func publishAppEventIfAvailable() { }
}
