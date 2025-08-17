//
//  RuleEngine.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-13.
//

import Foundation

final class RuleEngine {
    static let shared = RuleEngine()
    private init() { load() }

    private(set) var rules: [Rule] = []
    private let storeKey = "rules.v1"

    func add(_ rule: Rule) { rules.append(rule); save() }
    func update(_ rule: Rule) {
        guard let idx = rules.firstIndex(where: { $0.id == rule.id }) else { return }
        rules[idx] = rule; save()
    }
    func remove(_ rule: Rule) { rules.removeAll { $0.id == rule.id }; save() }

    func routeShortcut(now: Date = Date()) -> String? {
        if let r = rules.first(where: { $0.enabled && $0.when.matches(now: now) }) {
            return r.shortcut
        }
        let s = AppSettings.shared
        if !s.alternateShortcutName.isEmpty, s.cancelNextEvent == false {
            return s.alternateShortcutName
        }
        return s.shortcutName
    }

    private func save() {
        if let data = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(data, forKey: storeKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storeKey),
           let arr = try? JSONDecoder().decode([Rule].self, from: data) {
            rules = arr
        } else {
            rules = [
                Rule(name: "Weeknights",
                     when: .days([2,3,4,5,6]),
                     shortcut: "SleepTrigger Weeknight"),
                Rule(name: "Weekend",
                     when: .days([1,7]),
                     shortcut: "SleepTrigger Weekend")
            ]
        }
    }
}
