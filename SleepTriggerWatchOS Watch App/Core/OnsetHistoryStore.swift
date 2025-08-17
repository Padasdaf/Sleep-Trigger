//
//  OnsetHistoryStore.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation
import WatchConnectivity

struct SleepEvent: Codable, Identifiable {
    let id: UUID
    let date: Date
    let bpm: Double?
    let source: String // "watch"
}

@MainActor
final class OnsetHistoryStore: ObservableObject {
    static let shared = OnsetHistoryStore()

    @Published private(set) var recent: [SleepEvent] = []

    private let key = "watch.history"
    private let maxCount = 50

    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([SleepEvent].self, from: data) {
            recent = decoded
        }
    }

    func append(bpm: Double?) {
        let e = SleepEvent(id: UUID(), date: Date(), bpm: bpm, source: "watch")
        recent.append(e)
        if recent.count > maxCount { recent.removeFirst(recent.count - maxCount) }
        save()

        // Best effort: forward to iPhone for its history list
        if WCSession.isSupported(), WCSession.default.isReachable {
            let payload: [String: Any] = [
                "historyAdd": [
                    "id": e.id.uuidString,
                    "ts": e.date.timeIntervalSince1970,
                    "bpm": bpm as Any
                ]
            ]
            WCSession.default.sendMessage(payload, replyHandler: nil, errorHandler: nil)
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(recent) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
