//
//  WidgetRefresh.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-15.
//

import Foundation
import WidgetKit

@MainActor
enum WidgetRefresh {
    /// Store last onset in App Group & refresh widgets/complications.
    static func publishOnset(_ date: Date) {
        if let gd = UserDefaults(suiteName: AppGroupID.suite) {
            gd.set(date.timeIntervalSince1970, forKey: "lastOnset")
        }
        WidgetCenter.shared.reloadAllTimelines()
        Log.widgets.debug("Published onset to App Group & reloaded widgets")
    }
}
