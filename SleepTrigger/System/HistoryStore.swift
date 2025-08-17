//
//  HistoryStore.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation

// MARK: - Model

struct SleepEvent: Codable, Identifiable {
    enum Kind: String, Codable { case onset }
    let id: UUID
    let kind: Kind
    let date: Date
    let bpm: Double?
    let notes: String?

    init(kind: Kind,
         date: Date = Date(),
         bpm: Double? = nil,
         notes: String? = nil)
    {
        self.id = UUID()
        self.kind = kind
        self.date = date
        self.bpm = bpm
        self.notes = notes
    }
}

// MARK: - Store

/// JSON-in-App-Group for quick reads, plus a mirror insert to SQLite for future queries.
actor HistoryStore {
    static let shared = HistoryStore()

    private var events: [SleepEvent] = []
    private var loaded = false

    // JSON file in the shared App Group container
    private var url: URL {
        let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppGroupID.suite
        )!
        return container.appendingPathComponent("sleep_history.json")
    }

    // Lazy load on first use
    private func loadIfNeeded() {
        guard !loaded else { return }
        defer { loaded = true }
        guard let data = try? Data(contentsOf: url) else { return }
        if let decoded = try? JSONDecoder().decode([SleepEvent].self, from: data) {
            events = decoded
        }
    }

    private func save() {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        if let data = try? enc.encode(events) {
            try? data.write(to: url, options: .atomic)
        }
    }

    // --- APIs ---

    /// Original API you had.
    func appendOnset(date: Date) {
        append(date: date, bpm: nil)
    }

    /// Newer API used by SleepEventBridge.
    func append(date: Date, bpm: Double?) {
        loadIfNeeded()

        let event = SleepEvent(kind: .onset, date: date, bpm: bpm, notes: nil)
        events.append(event)

        pruneIfNeeded()
        save()

        // Mirror to SQLite so we can do richer queries later.
        SQLiteStore.shared.insertOnset(id: event.id, date: event.date, notes: nil)
    }

    /// Synchronous snapshot of all events, newest first.
    func all() -> [SleepEvent] {
        loadIfNeeded()
        return events.sorted { $0.date > $1.date }
    }

    /// Prunes local JSON file based on app setting.
    func pruneIfNeeded() {
        let days: Int = max(1, AppSettings.shared.dataRetentionDays)
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        events.removeAll { $0.date < cutoff }
    }
}
