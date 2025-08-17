//
//  HistoryView.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-14.
//

import SwiftUI
import Charts

@MainActor
struct HistoryView: View {
    @State private var events: [SleepEvent] = []
    @State private var tips: [Tip] = []

    // Exporting
    @State private var exporting = false
    @State private var exportURL: URL?

    // Controls
    @State private var windowDays: Int = 28
    private let choices = [14, 28, 90]

    var body: some View {
        NavigationStack {
            ScrollView {
                // Suggestions
                if !tips.isEmpty {
                    TipsSection(tips: tips)
                        .padding(.horizontal)
                        .padding(.top)
                }

                // Charts
                ChartSection(events: events, windowDays: windowDays)
                    .padding(.horizontal)
                    .padding(.top)

                // List
                ListSection(events: events)
                    .frame(minHeight: 320)
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Picker("", selection: $windowDays) {
                        ForEach(choices, id: \.self) { n in Text("\(n)d").tag(n) }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Export CSV") {
                            Task {
                                exportURL = await ExportManager.exportHistoryCSV()
                                exporting = true
                            }
                        }
                        Button("Bundle Logs (.gz)") {
                            Task {
                                exportURL = await RemoteLogBundler.bundle()
                                exporting = true
                            }
                        }
                        Button("Refresh") { Task { await load() } }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .task { await load() }
            .sheet(isPresented: $exporting) {
                if let u = exportURL { ShareSheet(activityItems: [u]) }
            }
        }
    }

    private func load() async {
        let list = await HistoryStore.shared.all()
        events = list
        tips = TipsEngine.tips(from: list)
    }
}

// MARK: - Subviews

private struct TipsSection: View {
    let tips: [Tip]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggestions").font(.headline)
            ForEach(tips) { t in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb").foregroundStyle(.yellow)
                    Text(t.text)
                }
                .padding(8)
                .background(.yellow.opacity(0.12), in: .rect(cornerRadius: 12))
            }
        }
    }
}

private struct ChartSection: View {
    let events: [SleepEvent]
    let windowDays: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Onsets by Day").font(.headline)

            // Use SQLite rollup for accuracy/perf
            let daily = HistoryDAO.recentDailyCounts(windowDays)
            Chart(daily, id: \.0) { (day, count) in
                BarMark(
                    x: .value("Day", day, unit: .day),
                    y: .value("Onsets", count)
                )
            }
            .frame(height: 180)

            // Light derived “typical bedtime” trend from the in-memory events
            let bedtime = bedtimeSeries(events, last: min(14, windowDays))
            if !bedtime.isEmpty {
                Text("Typical Bedtime (last \(min(14, windowDays)))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Chart(bedtime, id: \.0) { (date, hour) in
                    LineMark(
                        x: .value("Date", date),
                        y: .value("Hour", hour)
                    )
                }
                .frame(height: 160)
            }
        }
    }

    private func bedtimeSeries(_ list: [SleepEvent], last n: Int) -> [(Date, Int)] {
        let cal = Calendar.current
        let sorted = list.sorted { $0.date < $1.date }.suffix(n)
        return sorted.map { ($0.date, cal.component(.hour, from: $0.date)) }
    }
}

private struct ListSection: View {
    let events: [SleepEvent]
    private let df: DateFormatter = {
        let d = DateFormatter()
        d.dateStyle = .medium
        d.timeStyle = .short
        return d
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent").font(.headline).padding(.horizontal)
            if events.isEmpty {
                Text("No events yet")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 4)
            } else {
                ForEach(events) { e in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Sleep onset")
                            Text(df.string(from: e.date))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "moon.zzz").foregroundStyle(.blue.opacity(0.85))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    Divider().padding(.leading)
                }
            }
        }
    }
}

// MARK: - ShareSheet

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
