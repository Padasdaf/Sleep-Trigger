//
//  HRTrendAnalyzer.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation

/// Tracks HR baseline (long window) and short-term trend (slope).
final class HRTrendAnalyzer {
    private var baselineBuf: [(Date, Double)] = []
    private var trendBuf: [(Date, Double)] = []

    var baselineWindow: TimeInterval = 5 * 60     // 5 minutes
    var trendWindow: TimeInterval = 90            // 90 seconds

    func ingest(_ bpm: Double, at time: Date = .now) {
        baselineBuf.append((time, bpm))
        trendBuf.append((time, bpm))
        let baselineCut = time.addingTimeInterval(-baselineWindow)
        baselineBuf.removeAll { $0.0 < baselineCut }
        let trendCut = time.addingTimeInterval(-trendWindow)
        trendBuf.removeAll { $0.0 < trendCut }
    }

    var baselineMean: Double? {
        guard !baselineBuf.isEmpty else { return nil }
        return baselineBuf.map(\.1).reduce(0,+) / Double(baselineBuf.count)
    }

    /// Returns (latest - baseline) / baseline (negative when below baseline).
    var dropFraction: Double? {
        guard let baseline = baselineMean, let latest = trendBuf.last?.1 else { return nil }
        guard baseline > 0 else { return nil }
        return (latest - baseline) / baseline
    }

    /// Simple linear regression slope in bpm/second over the trend window.
    var slopeBPMPerSec: Double? {
        let pts = trendBuf
        guard pts.count >= 5 else { return nil }
        // x: seconds from first sample
        let t0 = pts.first!.0.timeIntervalSinceReferenceDate
        let xs = pts.map { $0.0.timeIntervalSinceReferenceDate - t0 }
        let ys = pts.map { $0.1 }

        let n = Double(xs.count)
        let sumX = xs.reduce(0,+), sumY = ys.reduce(0,+)
        let sumXX = xs.reduce(0) { $0 + $1*$1 }
        let sumXY = zip(xs, ys).reduce(0) { $0 + $1.0 * $1.1 }
        let denom = (n * sumXX - sumX * sumX)
        guard denom != 0 else { return nil }
        let slope = (n * sumXY - sumX * sumY) / denom
        return slope
    }
}
