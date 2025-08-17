//
//  SleepTriggerMacApp.swift
//  SleepTriggerMac
//
//  Created by Daniel Hu on 2025-08-14.
//

import SwiftUI

@main
struct SleepTriggerMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() } // no visible window
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var status: StatusItemController?
    private var cloud: CloudListener?

    func applicationDidFinishLaunching(_ notification: Notification) {
        status = StatusItemController()
        cloud = CloudListener { [weak self] date, source in
            self?.handleOnset(date, source: source)
        }
    }

    private func handleOnset(_ date: Date, source: String) {
        // Example actions on Mac:
        ScriptRunner.shared.pauseMedia()
        ScriptRunner.shared.enableFocus()
    }
}
