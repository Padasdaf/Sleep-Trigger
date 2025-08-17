//
//  MacNotificationManager.swift
//  SleepTriggerMac
//
//  Created by Daniel Hu on 2025-08-16.
//

import Foundation
import UserNotifications

@MainActor
final class MacNotificationManager {
    static let shared = MacNotificationManager()

    func requestPermissionIfNeeded() {
        let settings = MacSettings.shared
        guard settings.enableNotifications else { return }
        if settings.hasAskedNotificationAuth { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        settings.hasAskedNotificationAuth = true
    }

    func notifyOnset(date: Date) {
        guard MacSettings.shared.enableNotifications else { return }

        let content = UNMutableNotificationContent()
        let df = DateFormatter(); df.timeStyle = .short; df.dateStyle = .short
        content.title = "Sleep detected"
        content.body  = "Mirrored onset at \(df.string(from: date))."
        content.sound = .default

        let req = UNNotificationRequest(identifier: UUID().uuidString,
                                        content: content,
                                        trigger: nil)
        UNUserNotificationCenter.current().add(req)
    }
}
