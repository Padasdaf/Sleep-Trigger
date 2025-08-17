//
//  SharedStore.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation

// App Group suite used by the app + widget(s).
// Make sure this matches the suite you added in Signing & Capabilities.
enum AppGroup {
    static let suite = "group.com.danielhu.sleeptrigger"
}

struct SharedStore {
    static var defaults: UserDefaults? { UserDefaults(suiteName: AppGroup.suite) }

    /// Last detected sleep onset time written by the iOS/Watch app.
    static var lastOnset: Date? {
        guard let t = defaults?.double(forKey: "lastOnset"), t > 0 else { return nil }
        return Date(timeIntervalSince1970: t)
    }

    /// Placeholder until you wire the real “armed” state into the App Group.
    static var armed: Bool {
        defaults?.bool(forKey: "armed") ?? true
    }
}
