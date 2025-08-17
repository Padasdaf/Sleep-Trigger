//
//  StarterPacksView.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import SwiftUI

struct StarterPacksView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            Section(header: Text("Why a Master Shortcut?")) {
                Text("Running one well-built shortcut is smoother than launching several one-by-one. We'll help you create it in the Shortcuts app.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section(header: Text("Popular actions to include")) {
                Label("Pause Now Playing", systemImage: "pause.circle")
                Label("Enable Sleep Focus", systemImage: "moon.zzz")
                Label("Set alarm for +8 hours", systemImage: "alarm")
                Label("Dim brightness & volume", systemImage: "sun.min")
                Label("Run Home scene (lights off)", systemImage: "house")
            }

            Section {
                Button {
                    if let url = URL(string: "shortcuts://") {
                        openURL(url)
                    }
                } label: {
                    HStack {
                        Text("Open Shortcuts")
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                    }
                }

                Text("Create a new shortcut named **SleepTrigger Master**. Add any actions you like (pause media, Sleep Focus, alarm +8h, etc.). Then mark it as **Master** in Automations.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Create Master Shortcut")
    }
}
