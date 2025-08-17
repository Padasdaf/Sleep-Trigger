//
//  PhoneHistoryStore.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation
import Combine

struct PhoneSleepEvent: Codable, Identifiable {
    let id: UUID
    let date: Date
    let bpm: Double?
    let source: String // "watch"
}

@MainActor
final class PhoneHistoryStore: ObservableObject {
    static let shared = PhoneHistoryStore()

    @Published private(set) var events: [PhoneSleepEvent] = []

    private let key = "phone.history"
    private let maxCount = 200
    private let ud: UserDefaults

    private init() {
        ud = AppSettings.shared.groupDefaults ?? .standard
        if let data = ud.data(forKey: key),
           let decoded = try? JSONDecoder().decode([PhoneSleepEvent].self, from: data) {
            events = decoded
        }
    }

    func append(date: Date, bpm: Double? = nil) {
        let e = PhoneSleepEvent(id: UUID(), date: date, bpm: bpm, source: "watch")
        events.append(e)
        if events.count > maxCount { events.removeFirst(events.count - maxCount) }
        save()
    }

    func importFromWatchPayload(_ dict: [String: Any]) {
        guard let ts = dict["ts"] as? TimeInterval else { return }
        let bpm = dict["bpm"] as? Double
        append(date: Date(timeIntervalSince1970: ts), bpm: bpm)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(events) {
            ud.set(data, forKey: key)
        }
    }

    func exportJSONTempURL() -> URL? {
        guard let data = try? JSONEncoder().encode(events) else { return nil }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("sleep_trigger_history.json")
        try? data.write(to: url, options: .atomic)
        return url
    }
}
