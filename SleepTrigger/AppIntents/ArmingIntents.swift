//
//  ArmingIntents.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-13.
//

import AppIntents

struct ToggleArmedIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Armed"
    static var description = IntentDescription("Enable or disable SleepTrigger’s armed state.")

    @Parameter(title: "Armed")
    var armed: Bool

    func perform() async throws -> some IntentResult & ProvidesDialog {
        await MainActor.run { AppSettings.shared.armed = armed }
        return .result(dialog: "Armed is now \(armed ? "On" : "Off")")
    }
}

struct EnableNapModeIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Nap Mode"
    @Parameter(title: "Enabled") var enabled: Bool

    func perform() async throws -> some IntentResult & ProvidesDialog {
        await MainActor.run { AppSettings.shared.napModeEnabled = enabled }
        return .result(dialog: "Nap Mode \(enabled ? "enabled" : "disabled")")
    }
}

struct LastSleepOnsetIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Last Sleep Onset"

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let epoch = UserDefaults(suiteName: AppGroupID.suite)?
            .double(forKey: "lastOnset") ?? 0
        if epoch <= 0 { return .result(dialog: "No sleep onset detected yet.") }
        let d = Date(timeIntervalSince1970: epoch)
        let f = DateFormatter(); f.timeStyle = .short; f.dateStyle = .short
        return .result(dialog: "Last sleep onset: \(f.string(from: d))")
    }
}
