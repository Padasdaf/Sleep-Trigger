//
//  SQLiteStore.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation
import SQLite3

/// Shared SQLite store for simple analytics/history.
final class SQLiteStore {
    static let shared = SQLiteStore()

    private var db: OpaquePointer?

    private init() {
        open()
        runSchema()
    }

    // MARK: - Open / schema

    private func open() {
        // Put the DB in the App Group so widgets/companions could read it if needed.
        let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppGroupID.suite
        )!
        let url = container.appendingPathComponent("sleep.sqlite")

        if sqlite3_open_v2(url.path, &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, nil) != SQLITE_OK {
            print("SQLite open failed")
            db = nil
        }
    }

    private func runSchema() {
        guard let path = Bundle.main.path(forResource: "schema", ofType: "sql") else { return }
        // iOS 18+: use encoding initializer
        guard let sql = try? String(contentsOfFile: path, encoding: .utf8) else { return }
        _ = exec(sql)
    }

    @discardableResult
    private func exec(_ sql: String) -> Int32 {
        guard let db else { return SQLITE_ERROR }
        var err: UnsafeMutablePointer<Int8>?
        let rc = sqlite3_exec(db, sql, nil, nil, &err)
        if rc != SQLITE_OK, let err = err {
            print("SQLite exec error:", String(cString: err))
            sqlite3_free(err)
        }
        return rc
    }

    // MARK: - Inserts

    /// INSERT OR IGNORE a sleep onset row.
    func insertOnset(id: UUID = UUID(), date: Date, notes: String? = nil) {
        guard let db else { return }
        let sql = "INSERT OR IGNORE INTO sleep_onset (id, ts, notes) VALUES (?, ?, ?);"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }
        defer { sqlite3_finalize(stmt) }

        // Pass text as SQLITE_TRANSIENT so SQLite copies it.
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

        let uuidString = id.uuidString
        sqlite3_bind_text(stmt, 1, uuidString, -1, SQLITE_TRANSIENT)
        sqlite3_bind_double(stmt, 2, date.timeIntervalSince1970)

        if let notes {
            sqlite3_bind_text(stmt, 3, notes, -1, SQLITE_TRANSIENT)
        } else {
            sqlite3_bind_null(stmt, 3)
        }

        _ = sqlite3_step(stmt)
    }

    // MARK: - Queries

    /// Returns up to `limitDays` (Date-at-midnight, count) pairs for recent days (ascending by date).
    func dailyCounts(limitDays: Int) -> [(Date, Int)] {
        guard let db else { return [] }
        let limit = max(1, limitDays)

        // Cutoff so we don't scan the whole table.
        let cutoff = Date().addingTimeInterval(-Double(limit - 1) * 86_400).timeIntervalSince1970

        // Bucket by day using integer division of Unix time.
        // Later we convert the day bucket back to a Date at 00:00:00 (UTC).
        let sql = """
        SELECT CAST(ts / 86400.0 AS INTEGER) AS day_bucket, COUNT(*) AS c
        FROM sleep_onset
        WHERE ts >= ?
        GROUP BY day_bucket
        ORDER BY day_bucket ASC
        LIMIT ?;
        """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_double(stmt, 1, cutoff)
        sqlite3_bind_int(stmt, 2, Int32(limit))

        var out: [(Date, Int)] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            let dayBucket = sqlite3_column_int64(stmt, 0)        // integer days since 1970
            let count     = Int(sqlite3_column_int(stmt, 1))
            let dayStart  = Date(timeIntervalSince1970: Double(dayBucket) * 86_400.0)
            out.append((dayStart, count))
        }
        return out
    }

    deinit { if let db { sqlite3_close(db) } }
}
