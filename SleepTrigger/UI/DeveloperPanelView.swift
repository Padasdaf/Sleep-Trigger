//
//  DeveloperPanelView.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-15.
//

import SwiftUI

#if DEBUG
struct DeveloperPanelView: View {
    @State private var reliableWC = FeatureFlags.useReliableWC
    @State private var kvsDedup   = FeatureFlags.useKVSDedup
    @State private var useMetal   = FeatureFlags.useMetal
    @State private var useAsm     = FeatureFlags.useAsm
    @State private var status     = "Ready"

    var body: some View {
        NavigationStack {
            Form {
                Section("Feature Flags") {
                    Toggle("Reliable WC retry (watch → phone)", isOn: $reliableWC)
                    Toggle("KVS de-dup mirror events", isOn: $kvsDedup)
                    Toggle("Hint: Metal", isOn: $useMetal)
                    Toggle("Hint: ASM", isOn: $useAsm)
                    Button("Apply Flags") {
                        FeatureFlags.useReliableWC = reliableWC
                        FeatureFlags.useKVSDedup   = kvsDedup
                        FeatureFlags.useMetal      = useMetal
                        FeatureFlags.useAsm        = useAsm
                        status = "Applied at \(Date().formatted(date: .omitted, time: .standard))"
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section("Simulate") {
                    Button("Simulate Sleep Onset (now)") {
                        SleepEventBridge.shared.handleSleepDetected(now: Date())
                        status = "Simulated onset sent"
                    }
                }

                Section("Status") {
                    Text(status).font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Developer")
        }
    }
}
#endif
