//
//  DiagnosticsView.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct DiagnosticsView: View {
    @StateObject private var wc = PhoneConnectivityManager.shared
    @ObservedObject private var history = EventHistoryStore.shared

    @State private var hrPoints: [(Date, Double)] = []
    @State private var loadingHR = false
    @State private var hrError: String?
    @State private var sleepScore: Int?

    private let df: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none; f.timeStyle = .medium
        return f
    }()

    var body: some View {
        List {
            // Connectivity ----------------------------------------------------
            Section(header: Text("Connectivity")) {
                HStack {
                    Circle().frame(width: 10).foregroundStyle(wc.isReachable ? .green : .red)
                    Text(wc.isReachable ? "Watch reachable" : "Watch not reachable")
                }
                if let t = wc.lastOnsetAt {
                    Text("Last onset: \(df.string(from: t))")
                }
            }

            // HealthKit permissions ------------------------------------------
            Section(header: Text("Permissions")) {
                HStack {
                    Label("Heart Rate", systemImage: "heart.fill")
                    Spacer()
                    Text(HealthKitManager.heartRateStatusString())
                        .foregroundStyle(.secondary)
                }
            }

            // Recent detections ----------------------------------------------
            Section(header: Text("Recent detections")) {
                if history.events.isEmpty {
                    Text("No events recorded").foregroundStyle(.secondary)
                } else {
                    ForEach(history.events, id: \.self) { d in
                        Text(df.string(from: d))
                    }
                    Button(role: .destructive) { history.clear() } label: {
                        Text("Clear history")
                    }
                }
            }

            // Heart rate preview ---------------------------------------------
            Section(header: Text("Heart rate (last 60 min)")) {
                if loadingHR { ProgressView() }
                if let hrError { Text(hrError).foregroundStyle(.red) }
                #if canImport(Charts)
                if !hrPoints.isEmpty {
                    Chart {
                        ForEach(hrPoints, id: \.0) { (t, v) in
                            LineMark(x: .value("Time", t), y: .value("BPM", v))
                        }
                    }
                    .frame(height: 180)
                } else if !loadingHR {
                    Text("No data").foregroundStyle(.secondary)
                }
                #else
                Text("Update to iOS 16+ for charts").foregroundStyle(.secondary)
                #endif

                Button("Refresh HR") { Task { await loadHR() } }
            }

            // Sleep likelihood (from HR) -------------------------------------
            Section(header: Text("Sleep likelihood")) {
                if let s = sleepScore {
                    Gauge(value: Double(s), in: 0...100) { Text("Likelihood") }
                    currentValueLabel: { Text("\(s)") }
                    .tint(color(for: s))
                    Text(label(for: s)).font(.caption).foregroundStyle(.secondary)
                } else if !loadingHR {
                    Text("Insufficient HR data").foregroundStyle(.secondary)
                }
            }

            // Demo tools (no Watch required) ---------------------------------
            #if DEBUG
            Section(header: Text("Demo")) {
                Button("Simulate Sleep Now") {
                    Task { @MainActor in
                        DemoTools.simulateSleepNow()
                        await loadHistoryList()
                    }
                }
                Button("Seed 14 days of history") {
                    Task { @MainActor in
                        DemoTools.seedSampleHistory(days: 14)
                        await loadHistoryList()
                    }
                }
            }
            #endif

            // Shortcuts quick link -------------------------------------------
            Section(header: Text("Shortcuts")) {
                Button("Open Shortcuts") {
                    if let url = URL(string: "shortcuts://") { UIApplication.shared.open(url) }
                }
            }
        }
        .task { await loadHR(); await loadHistoryList() }
        .navigationTitle("Diagnostics")
    }

    // MARK: - Helpers

    private func loadHR() async {
        loadingHR = true; hrError = nil
        do {
            hrPoints = try await HealthKitManager.fetchRecentHeartRate(minutes: 60)
            // Optional safety: simple HR-based score (if you kept SleepScore)
            sleepScore = SleepScore.fromBPMSeries(hrPoints)
        } catch {
            hrError = error.localizedDescription
            hrPoints = []
            sleepScore = nil
        }
        loadingHR = false
    }

    private func loadHistoryList() async {
        let list = await HistoryStore.shared.all()
        history.events = list.map { $0.date }
    }

    private func color(for score: Int) -> Color {
        switch score {
        case ..<35:   return .red
        case 35..<65: return .orange
        default:      return .green
        }
    }
    private func label(for score: Int) -> String {
        switch score {
        case ..<35:   return "Likely Awake"
        case 35..<65: return "Possibly Asleep"
        default:      return "Likely Asleep"
        }
    }
}
