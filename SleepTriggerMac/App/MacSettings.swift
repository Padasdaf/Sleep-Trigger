//
//  MacSettings.swift
//  SleepTriggerMac
//
//  Created by Daniel Hu on 2025-08-16.
//

import Foundation

@MainActor
final class MacSettings: ObservableObject {
    static let shared = MacSettings()

    // User-visible prefs
    @Published var enableNotifications: Bool
    @Published var alsoPauseMedia: Bool
    @Published var shortcutName: String

    private struct Key {
        static let enableNotifications = "mac.enableNotifications"
        static let alsoPauseMedia     = "mac.alsoPauseMedia"
        static let shortcutName       = "mac.shortcutName"
        static let askedNotifAuth     = "mac.askedNotifAuth"
    }

    private let d = UserDefaults.standard

    private init() {
        enableNotifications = d.object(forKey: Key.enableNotifications) as? Bool ?? true
        alsoPauseMedia      = d.object(forKey: Key.alsoPauseMedia)     as? Bool ?? false
        shortcutName        = d.string(forKey: Key.shortcutName) ?? ""
    }

    func save() {
        d.set(enableNotifications, forKey: Key.enableNotifications)
        d.set(alsoPauseMedia,      forKey: Key.alsoPauseMedia)
        d.set(shortcutName,        forKey: Key.shortcutName)
    }

    var hasAskedNotificationAuth: Bool {
        get { d.bool(forKey: Key.askedNotifAuth) }
        set { d.set(newValue, forKey: Key.askedNotifAuth) }
    }
}
