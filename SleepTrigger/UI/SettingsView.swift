//
//  SettingsView.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        Form {
            Section {
                Toggle("Armed (enable sleep trigger)", isOn: $settings.armed)
            } footer: {
                Text("When Armed is on, SleepTrigger publishes the event and runs your Shortcut when sleep is detected.")
            }
        }
        .navigationTitle("Settings")
    }
}
