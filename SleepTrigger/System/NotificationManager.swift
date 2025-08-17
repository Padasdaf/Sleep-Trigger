//
//  NotificationManager.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//


import Foundation
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // Handle taps on our actionable notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "RUN_ALT":
            AppSettings.shared.cancelNextEvent = false
            Task { @MainActor in
                SleepEventBridge.shared.runAlternateNow()
            }

        case "SNOOZE_10":
            // Public convenience that re-evaluates the route when the hold fires.
            Task { @MainActor in
                SleepEventBridge.shared.scheduleHold(seconds: 600)
            }

        case "CANCEL_ONCE":
            AppSettings.shared.cancelNextEvent = true

        default:
            break
        }
        completionHandler()
    }
}

extension NotificationManager {
    /// Matches the call site in `SleepTriggerApp`.
    @MainActor
    func requestPermissionIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            // Register categories/actions once we’ve asked for permission.
            let runAlt   = UNNotificationAction(identifier: "RUN_ALT",
                                                title: "Run Alternate",
                                                options: [])
            let snooze10 = UNNotificationAction(identifier: "SNOOZE_10",
                                                title: "Snooze 10 min",
                                                options: [])
            let cancel   = UNNotificationAction(identifier: "CANCEL_ONCE",
                                                title: "Cancel Once",
                                                options: .destructive)

            let cat = UNNotificationCategory(identifier: "SLEEP_DETECTED",
                                             actions: [runAlt, snooze10, cancel],
                                             intentIdentifiers: [],
                                             options: [])
            center.setNotificationCategories([cat])
        }
    }
    
    @MainActor
    func notifySleepDetected() {
        let center = UNUserNotificationCenter.current()

        // Make sure categories exist (harmless if already set)
        requestPermissionIfNeeded()

        let content = UNMutableNotificationContent()
        content.title = "Sleep detected"
        content.body  = "Tap to run your Shortcut, snooze 10m, or cancel once."
        content.sound = .default
        content.categoryIdentifier = "SLEEP_DETECTED"

        // Deliver immediately
        let req = UNNotificationRequest(
            identifier: "sleep_detected_now",
            content: content,
            trigger: nil
        )
        center.add(req)
    }

}
