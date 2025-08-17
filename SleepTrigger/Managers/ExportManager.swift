//
//  ExportManager.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-15.
//

import Foundation

enum ExportManager {

    // MARK: - Public async API

    /// Writes a CSV (date,count) for the last `days` to a temp file on a background queue.
    /// Use this from SwiftUI with `await` to avoid doing file I/O on the main thread.
    static func exportHistoryCSV(days: Int = 90) async -> URL? {
        await withCheckedContinuation { cont in
            DispatchQueue.global(qos: .utility).async {
                let url = exportHistoryCSVSync(days: days)
                cont.resume(returning: url)
            }
        }
    }

    // MARK: - Public synchronous API (kept for callers that don't need async)

    /// Synchronous version. If you call this from UI code, prefer the async wrapper above.
    static func exportHistoryCSVSync(days: Int = 90) -> URL? {
        let rows = HistoryDAO.recentDailyCounts(days)

        var csv = "date,count\n"

        // Stable ascending order
        let sorted = rows.sorted { $0.0 < $1.0 }

        let fmt = iso8601Formatter
        for (d, c) in sorted {
            csv += "\(fmt.string(from: d)),\(c)\n"
        }

        // Unique file name to avoid collisions in the temp directory.
        let filename = "sleep_history_\(timestampFormatter.string(from: Date())).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("ExportManager: CSV write failed: \(error)")
            return nil
        }
    }

    // MARK: - Helpers

    /// Reuse formatters (they’re expensive to create).
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let timestampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd_HHmmss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}
