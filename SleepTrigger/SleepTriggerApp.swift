//
//  SleepTriggerApp.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import SwiftUI

@main
struct SleepTriggerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    PhoneConnectivityManager.shared.start()
                    CloudSyncListener.shared.start()
                    NotificationManager.shared.requestPermissionIfNeeded()
                }
        }
    }
}
