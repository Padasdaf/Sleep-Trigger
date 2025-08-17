//
//  Rule.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-13.
//

import Foundation

enum RuleWhen: Codable, Equatable {
    case always
    case hours(Int, Int)          // startHour..endHour (0–23)
    case days([Int])              // 1=Sun ... 7=Sat

    func matches(now: Date = Date()) -> Bool {
        let cal = Calendar.current
        switch self {
        case .always:
            return true
        case .hours(let start, let end):
            let h = cal.component(.hour, from: now)
            if start <= end { return (start...end).contains(h) }
            return h >= start || h <= end
        case .days(let dows):
            let dow = cal.component(.weekday, from: now) // 1..7
            return dows.contains(dow)
        }
    }
}

struct Rule: Identifiable, Codable, Equatable {
    var id: UUID = .init()
    var name: String
    var when: RuleWhen
    var shortcut: String
    var enabled: Bool = true
}
