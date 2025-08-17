//
//  CalibrationView.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

import SwiftUI

struct CalibrationView: View {
    @StateObject private var monitor = SleepMonitor()
    @State private var values: [Double] = []

    var body: some View {
        VStack(spacing: 8) {
            Text("Calibration").font(.headline)

            if let bpm = monitor.currentBPM {
                Text("HR: \(Int(bpm)) bpm").font(.caption2)
            }
            Text(String(format: "Still: %.0f%%", monitor.stillnessScore * 100)).font(.caption2)
            Text("State: \(label(monitor.state))").font(.caption2)

            DebugChartView(values: values)

            HStack {
                if monitor.isRunning {
                    Button("Stop") { stop() }
                } else {
                    Button("Start") { start() }
                }
            }
        }
        .onReceive(monitor.$currentBPM.compactMap { $0 }) { bpm in
            values.append(bpm)
            if values.count > 60 { values.removeFirst() }
        }
        .padding()
    }

    private func start() {
        try? WorkoutSessionManager.shared.start()
        monitor.start()
    }
    private func stop() {
        monitor.stop()
        WorkoutSessionManager.shared.stop()
    }
    private func label(_ s: SleepState) -> String {
        switch s { case .awake: "Awake"; case .drowsy: "Drowsy"; case .asleep: "Asleep" }
    }
}
