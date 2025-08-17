//
//  SleepTriggerWidgets.swift
//  SleepTriggerWidgets
//
//  Created by Daniel Hu on 2025-08-12.
//

import WidgetKit
import SwiftUI

// MARK: - Shared timeline model & provider

struct SleepEntry: TimelineEntry {
    let date: Date
    let lastOnset: Date?
    let armed: Bool
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SleepEntry {
        SleepEntry(date: Date(), lastOnset: Date().addingTimeInterval(-3600), armed: true)
    }
    func getSnapshot(in context: Context, completion: @escaping (SleepEntry) -> Void) {
        completion(SleepEntry(date: Date(),
                              lastOnset: SharedStore.lastOnset,
                              armed: SharedStore.armed))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SleepEntry>) -> Void) {
        let entry = SleepEntry(date: Date(),
                               lastOnset: SharedStore.lastOnset,
                               armed: SharedStore.armed)
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300))))
    }
}

// MARK: - Views

struct SleepWidgetView_iOS: View {
    var entry: SleepEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Circle().frame(width: 8).foregroundStyle(entry.armed ? .green : .red)
                Text(entry.armed ? "Armed" : "Idle").font(.caption2)
            }
            Text("SleepTrigger").font(.headline)
            Text(lastText(entry.lastOnset)).font(.caption2).foregroundStyle(.secondary)
        }
        .padding(8)
    }
    private func lastText(_ d: Date?) -> String {
        guard let d else { return "No detections" }
        let f = DateFormatter(); f.timeStyle = .short; f.dateStyle = .none
        return "Last: \(f.string(from: d))"
    }
}

struct SleepComplicationView_watchOS: View {
    var entry: SleepEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Circle().frame(width: 6).foregroundStyle(entry.armed ? .green : .red)
                Text(entry.armed ? "Armed" : "Idle").font(.caption2)
            }
            Text(lastText(entry.lastOnset)).font(.caption2).foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
    }
    private func lastText(_ d: Date?) -> String {
        guard let d else { return "—" }
        let f = DateFormatter(); f.timeStyle = .short; f.dateStyle = .none
        return f.string(from: d)
    }
}

// MARK: - Widgets per-OS (families guarded so watch never sees .systemSmall)

#if os(iOS)
struct SleepTriggerWidget_iOS: Widget {
    let kind = "SleepTriggerWidget_iOS"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SleepWidgetView_iOS(entry: entry)
        }
        .configurationDisplayName("SleepTrigger")
        .description("Armed status and last detection time.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
#endif

#if os(watchOS)
struct SleepTriggerComplication_watchOS: Widget {
    let kind = "SleepTriggerComplication_watchOS"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SleepComplicationView_watchOS(entry: entry)
        }
        .configurationDisplayName("SleepTrigger")
        .description("Armed status and last detection time.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}
#endif
