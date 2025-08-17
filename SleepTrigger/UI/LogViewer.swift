//
//  LogViewer.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-15.
//

import SwiftUI
import OSLog

struct LogViewer: View {
    @State private var lines: [String] = []
    @State private var isLoading = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Recent Logs").font(.headline)
                Spacer()
                Button("Refresh") { load() }.disabled(isLoading)
            }
            .padding(.bottom, 8)

            if isLoading {
                ProgressView()
            } else if lines.isEmpty {
                Text("No logs found").foregroundStyle(.secondary)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 6) {
                        ForEach(lines, id: \.self) { Text($0).font(.system(.caption, design: .monospaced)) }
                    }
                }
            }
        }
        .task { load() }
    }

    private func load() {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let store = try OSLogStore(scope: .currentProcessIdentifier)

                // Position is NOT throwing; remove `try` to satisfy the compiler.
                let since = store.position(timeIntervalSinceLatestBoot: 60 * 60) // last hour

                let entries = try store.getEntries(at: since)
                let fmt = DateFormatter()
                fmt.dateFormat = "HH:mm:ss.SSS"

                var out: [String] = []
                out.reserveCapacity(200)

                for case let e as OSLogEntryLog in entries {
                    out.append("\(fmt.string(from: e.date)) [\(e.category)] \(e.composedMessage)")
                }

                lines = out.suffix(200)
            } catch {
                lines = ["OSLogStore error: \(error.localizedDescription)"]
            }
        }
    }
}
