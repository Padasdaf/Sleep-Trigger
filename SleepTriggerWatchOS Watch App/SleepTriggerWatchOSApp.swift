//
//  SleepTriggerWatchOSApp.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-12.
//

import SwiftUI

@main
struct SleepTriggerWatchOSApp: App {
    // Keeping a strong reference is fine; the manager activates itself in init.
    @StateObject private var wc = WatchConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
