//
//  AppDelegate.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // Register notification categories
        let snooze = UNNotificationAction(identifier: "SNOOZE_10", title: "Snooze 10 min", options: [])
        let cancel = UNNotificationAction(identifier: "CANCEL_TONIGHT", title: "Cancel tonight", options: [.destructive])
        let alternate = UNTextInputNotificationAction(identifier: "RUN_ALTERNATE",
                                                      title: "Run alternate shortcut",
                                                      options: [],
                                                      textInputButtonTitle: "Run",
                                                      textInputPlaceholder: "Shortcut name")
        let category = UNNotificationCategory(identifier: "SLEEP_DETECTED",
                                              actions: [snooze, cancel, alternate],
                                              intentIdentifiers: [],
                                              options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Handle actions
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let settings = AppSettings.shared
        switch response.actionIdentifier {
        case "SNOOZE_10":
            // Delay next pending run by 10 minutes (via global hold)
            settings.holdSecondsBeforeRun = max(settings.holdSecondsBeforeRun, 10 * 60)
        case "CANCEL_TONIGHT":
            settings.cancelNextEvent = true
        case "RUN_ALTERNATE":
            if let textResp = response as? UNTextInputNotificationResponse {
                settings.alternateShortcutName = textResp.userText
            }
        default:
            break
        }
        completionHandler()
    }
}
