//
//  EventHistoryStore.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation
import Combine

final class EventHistoryStore: ObservableObject {
    static let shared = EventHistoryStore()
    private let key = "sleepEvents.v1"

    @Published var events: [Date] = [] {
        didSet { persist() }
    }

    private init() { load() }

    func add(_ date: Date) { events.insert(date, at: 0) }
    func clear() { events.removeAll() }

    private func load() {
        let times = UserDefaults.standard.array(forKey: key) as? [TimeInterval] ?? []
        self.events = times.map { Date(timeIntervalSince1970: $0) }.sorted(by: >)
    }
    private func persist() {
        let times = events.map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(times, forKey: key)
    }
}
