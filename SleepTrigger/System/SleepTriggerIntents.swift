//
//  SleepTriggerIntents.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation
import AppIntents

// MARK: - Intents

struct ArmSleepTrigger: AppIntent {
    static var title: LocalizedStringResource = "Arm SleepTrigger"
    static var description = IntentDescription("Arms SleepTrigger so detections can trigger your automation.")

    @MainActor
    func perform() async throws -> some IntentResult {
        AppSettings.shared.armed = true
        return .result()
    }
}

struct DisarmSleepTrigger: AppIntent {
    static var title: LocalizedStringResource = "Disarm SleepTrigger"
    static var description = IntentDescription("Disarms SleepTrigger so detections will not trigger your automation.")

    @MainActor
    func perform() async throws -> some IntentResult {
        AppSettings.shared.armed = false
        return .result()
    }
}

struct TestSleepTrigger: AppIntent {
    static var title: LocalizedStringResource = "Test SleepTrigger"
    static var description = IntentDescription("Sends a test sleep-onset event as if it came from the Watch.")

    @MainActor
    func perform() async throws -> some IntentResult {
        SleepEventBridge.shared.handleSleepDetected()
        return .result()
    }
}

// MARK: - App Shortcuts provider

@available(iOS 16.0, *)
struct SleepTriggerShortcuts: AppShortcutsProvider {

    // NOTE: the protocol requires **appShortcuts**, not "shortcuts".
    static var appShortcuts: [AppShortcut] {
        if #available(iOS 17.0, *) {
            return [
                AppShortcut(
                    intent: ArmSleepTrigger(),
                    phrases: ["Arm SleepTrigger", "Turn on SleepTrigger"],
                    shortTitle: "Arm",
                    systemImageName: "shield.lefthalf.filled"
                ),
                AppShortcut(
                    intent: DisarmSleepTrigger(),
                    phrases: ["Disarm SleepTrigger", "Turn off SleepTrigger"],
                    shortTitle: "Disarm",
                    systemImageName: "shield.slash"
                ),
                AppShortcut(
                    intent: TestSleepTrigger(),
                    phrases: ["Test SleepTrigger"],
                    shortTitle: "Test",
                    systemImageName: "testtube.2"
                )
            ]
        } else {
            // iOS 16 initializer (no shortTitle/systemImageName)
            return [
                AppShortcut(intent: ArmSleepTrigger(),    phrases: ["Arm SleepTrigger"]),
                AppShortcut(intent: DisarmSleepTrigger(), phrases: ["Disarm SleepTrigger"]),
                AppShortcut(intent: TestSleepTrigger(),   phrases: ["Test SleepTrigger"])
            ]
        }
    }
}
