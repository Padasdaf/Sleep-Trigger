//
//  AutomationsStore.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation
import Combine

final class AutomationsStore: ObservableObject {
    static let shared = AutomationsStore()
    private let key = "automations.v1"

    @Published var items: [AutomationItem] = [] {
        didSet { persist() }
    }

    private init() { load() }

    func add(_ name: String) {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        items.append(AutomationItem(name: name))
    }
    func remove(_ indexSet: IndexSet) { items.remove(atOffsets: indexSet) }
    func move(from: IndexSet, to: Int) { items.move(fromOffsets: from, toOffset: to) }
    func setMaster(_ item: AutomationItem) {
        items = items.map { var m = $0; m.isMaster = (m.id == item.id); return m }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        if let decoded = try? JSONDecoder().decode([AutomationItem].self, from: data) {
            self.items = decoded
        }
    }
    private func persist() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
