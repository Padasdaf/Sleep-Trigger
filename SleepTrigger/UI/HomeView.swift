//
//  HomeView.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var wc = PhoneConnectivityManager.shared
    @ObservedObject private var history = EventHistoryStore.shared
    @ObservedObject private var settings = AppSettings.shared

    private let df: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .medium
        f.dateStyle = .none
        return f
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GlassCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SleepTrigger")
                                .font(.largeTitle.bold())
                            HStack(spacing: 8) {
                                Circle().frame(width: 10).foregroundStyle(wc.isReachable ? .green : .red)
                                Text(wc.isReachable ? "Watch reachable" : "Watch not reachable")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            if let t = wc.lastOnsetAt {
                                Text("Last sleep onset: \(df.string(from: t))")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("No detections yet")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                }

                NavigationLink {
                    StarterPacksView()
                } label: {
                    GlassCard {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Set up a Master Shortcut")
                                    .font(.headline)
                                Text("One tap to open Shortcuts and build a powerful 'Sleep Trigger' workflow.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.forward.app").font(.title3)
                        }
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent detections").font(.headline)
                        if history.events.isEmpty {
                            Text("No events yet").font(.footnote).foregroundStyle(.secondary)
                        } else {
                            ForEach(history.events.prefix(5), id: \.self) { d in
                                Text("• \(df.string(from: d))").font(.footnote)
                            }
                        }
                    }
                }
                
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Trigger behavior").font(.headline)
                        Toggle("Nap Mode (shorter detection)", isOn: $settings.napModeEnabled)
                        Toggle("Use sleep window", isOn: $settings.gatingEnabled)
                        if settings.gatingEnabled {
                            HStack {
                                Stepper("Start: \(settings.gateStartHour):00", value: $settings.gateStartHour, in: 0...23)
                                Stepper("End: \(settings.gateEndHour):00", value: $settings.gateEndHour, in: 0...23)
                            }.font(.footnote)
                        }
                        Stepper("Hold before run: \(settings.holdSecondsBeforeRun)s", value: $settings.holdSecondsBeforeRun, in: 0...600)
                        Toggle("Write onset to Health", isOn: $settings.writeSleepToHealth)
                    }
                }
            }
            .padding()
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Home")
    }
}
