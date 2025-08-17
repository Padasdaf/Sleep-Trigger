//
//  HistoryDAO.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation

enum HistoryDAO {
    static func recordOnset(_ date: Date) {
        SQLiteStore.shared.insertOnset(date: date)
    }

    static func recentDailyCounts(_ days: Int = 28) -> [(Date, Int)] {
        SQLiteStore.shared.dailyCounts(limitDays: days)
    }
}
