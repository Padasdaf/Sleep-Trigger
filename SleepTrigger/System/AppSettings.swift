//
//  AppSettings.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    // MARK: - User-togglable settings

    // Arm/disarm
    @Published var armed: Bool { didSet { d.set(armed, forKey: K.armed) } }

    // Shortcuts & timing
    @Published var shortcutName: String { didSet { d.set(shortcutName, forKey: K.shortcutName) } }
    @Published var alternateShortcutName: String { didSet { d.set(alternateShortcutName, forKey: K.altShortcutName) } }
    @Published var holdSecondsBeforeRun: Int { didSet { d.set(holdSecondsBeforeRun, forKey: K.holdSecondsBeforeRun) } }
    @Published var postAsleepLockoutMinutes: Int { didSet { d.set(postAsleepLockoutMinutes, forKey: K.postAsleepLockoutMinutes) } }

    // Modes & gating
    @Published var napModeEnabled: Bool { didSet { d.set(napModeEnabled, forKey: K.napModeEnabled) } }
    @Published var gatingEnabled: Bool { didSet { d.set(gatingEnabled, forKey: K.gatingEnabled) } }
    @Published var gateStartHour: Int { didSet { d.set(gateStartHour, forKey: K.gateStartHour) } } // 0–23
    @Published var gateEndHour: Int { didSet { d.set(gateEndHour, forKey: K.gateEndHour) } }     // 0–23

    // Health
    @Published var writeSleepToHealth: Bool { didSet { d.set(writeSleepToHealth, forKey: K.writeSleepToHealth) } }

    // One-shot cancel (from notification action)
    @Published var cancelNextEvent: Bool { didSet { d.set(cancelNextEvent, forKey: K.cancelNextEvent) } }

    // “Smart alarm” & housekeeping
    @Published var smartAlarmEnabled: Bool { didSet { d.set(smartAlarmEnabled, forKey: K.smartAlarmEnabled) } }
    @Published var smartAlarmWindowMinutes: Int { didSet { d.set(smartAlarmWindowMinutes, forKey: K.smartAlarmWindowMinutes) } }
    @Published var iCloudMirrorEnabled: Bool { didSet { d.set(iCloudMirrorEnabled, forKey: K.iCloudMirrorEnabled) } }
    @Published var dataRetentionDays: Int { didSet { d.set(dataRetentionDays, forKey: K.dataRetentionDays) } }

    // Onboarding
    @Published var hasCompletedOnboarding: Bool { didSet { d.set(hasCompletedOnboarding, forKey: K.hasCompletedOnboarding) } }

    // Shared (App Group) store for widgets/complications
    let groupDefaults = UserDefaults(suiteName: AppGroupID.suite)

    // MARK: - Init / Storage

    private let d = UserDefaults.standard
    private init() {
        armed                        = d.object(forKey: K.armed) as? Bool ?? true
        shortcutName                 = d.string(forKey: K.shortcutName) ?? "SleepTrigger Master"
        alternateShortcutName        = d.string(forKey: K.altShortcutName) ?? ""
        holdSecondsBeforeRun         = d.object(forKey: K.holdSecondsBeforeRun) as? Int ?? 8
        postAsleepLockoutMinutes     = d.object(forKey: K.postAsleepLockoutMinutes) as? Int ?? 20

        napModeEnabled               = d.object(forKey: K.napModeEnabled) as? Bool ?? false
        gatingEnabled                = d.object(forKey: K.gatingEnabled) as? Bool ?? false
        gateStartHour                = d.object(forKey: K.gateStartHour) as? Int ?? 20
        gateEndHour                  = d.object(forKey: K.gateEndHour) as? Int ?? 11

        writeSleepToHealth           = d.object(forKey: K.writeSleepToHealth) as? Bool ?? false
        cancelNextEvent              = d.object(forKey: K.cancelNextEvent) as? Bool ?? false

        smartAlarmEnabled            = d.object(forKey: K.smartAlarmEnabled) as? Bool ?? false
        smartAlarmWindowMinutes      = d.object(forKey: K.smartAlarmWindowMinutes) as? Int ?? 10
        iCloudMirrorEnabled          = d.object(forKey: K.iCloudMirrorEnabled) as? Bool ?? false
        dataRetentionDays            = d.object(forKey: K.dataRetentionDays) as? Int ?? 30

        hasCompletedOnboarding       = d.object(forKey: K.hasCompletedOnboarding) as? Bool ?? false
    }

    private enum K {
        static let armed = "armed"

        static let shortcutName = "shortcutName"
        static let altShortcutName = "alternateShortcutName"
        static let holdSecondsBeforeRun = "holdSecondsBeforeRun"
        static let postAsleepLockoutMinutes = "postAsleepLockoutMinutes"

        static let napModeEnabled = "napModeEnabled"
        static let gatingEnabled  = "gatingEnabled"
        static let gateStartHour  = "gateStartHour"
        static let gateEndHour    = "gateEndHour"

        static let writeSleepToHealth = "writeSleepToHealth"
        static let cancelNextEvent    = "cancelNextEvent"

        static let smartAlarmEnabled       = "smartAlarmEnabled"
        static let smartAlarmWindowMinutes = "smartAlarmWindowMinutes"
        static let iCloudMirrorEnabled     = "iCloudMirrorEnabled"
        static let dataRetentionDays       = "dataRetentionDays"

        static let hasCompletedOnboarding  = "hasCompletedOnboarding"
    }
}
