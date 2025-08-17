//
//  ContentView.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-12.
//

import SwiftUI
import WatchConnectivity
import WatchKit

struct ContentView: View {
    @StateObject private var monitor = SleepMonitor()
    @State private var reachable = WCSession.isSupported() ? WCSession.default.isReachable : false

    private var stateText: String {
        switch monitor.state {
        case .awake:  return "Awake"
        case .drowsy: return "Drowsy"
        case .asleep: return "Asleep"
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            // Reachability + title
            HStack(spacing: 8) {
                Circle()
                    .frame(width: 8)
                    .foregroundStyle(reachable ? .green : .red)
                    .animation(.easeInOut(duration: 0.2), value: reachable)
                Text(reachable ? "iPhone reachable" : "No iPhone")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }

            Text("SleepTrigger")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let bpm = monitor.currentBPM {
                Gauge(value: bpm, in: 40...150) {
                    Text("HR")
                } currentValueLabel: {
                    Text("\(Int(bpm))")
                }
                .gaugeStyle(.accessoryCircularCapacity)
            }

            ProgressView(value: monitor.stillnessScore, total: 1) {
                Text("Stillness").font(.caption2)
            } currentValueLabel: {
                Text("\(Int(monitor.stillnessScore * 100))%").font(.caption2)
            }

            Text(stateText)
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(colorForState()))
                .foregroundStyle(.white)

            if monitor.isRunning {
                Button("Stop Monitoring") {
                    WKInterfaceDevice.current().play(.stop)
                    monitor.stop()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Start Monitoring") {
                    WKInterfaceDevice.current().play(.start)
                    monitor.start()
                }
                .buttonStyle(.borderedProminent)
            }

            #if DEBUG
            Button("Send Test Sleep Onset") {
                WatchConnectivityManager.shared.sendTestSleepOnset()
                if WCSession.isSupported() { reachable = WCSession.default.isReachable }
            }
            .font(.caption2)
            #endif

            Spacer(minLength: 0)
        }
        .padding()
        .onAppear {
            if WCSession.isSupported() { reachable = WCSession.default.isReachable }
        }
    }

    private func colorForState() -> Color {
        switch monitor.state {
        case .awake:  return .blue
        case .drowsy: return .orange
        case .asleep: return .green
        }
    }
}
