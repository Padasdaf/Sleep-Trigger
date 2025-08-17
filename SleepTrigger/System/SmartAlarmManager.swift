//
//  SmartAlarmManager.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation
import UserNotifications

final class SmartAlarmManager {
    static let shared = SmartAlarmManager()

    /// Schedules a gentle alarm after sleep onset, if the user enabled it.
    func scheduleIfEnabled(after onset: Date) {
        let settings = AppSettings.shared
        guard settings.smartAlarmEnabled else { return }

        let minutes = max(1, settings.smartAlarmWindowMinutes)
        let fire = onset.addingTimeInterval(TimeInterval(minutes * 60))

        let content = UNMutableNotificationContent()
        content.title = "Smart Alarm"
        content.body  = "Gentle alarm after sleep onset."
        content.sound = .default
        content.categoryIdentifier = "SMART_ALARM"

        let trig = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, fire.timeIntervalSinceNow),
            repeats: false
        )
        let req = UNNotificationRequest(identifier: "smart_alarm", content: content, trigger: trig)
        UNUserNotificationCenter.current().add(req)
    }
}
