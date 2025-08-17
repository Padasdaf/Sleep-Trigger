//
//  RingLogger.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation

public struct RingLogger {
    public struct Row: Codable {
        public let t: TimeInterval
        public let hr: Double?     // can be nil
        public let still: Double
        public let drop: Double
        public let slope: Double
        public let propensity: Double
        public let stateRaw: Int   // 0 awake, 1 drowsy, 2 asleep
    }

    private let capacity: Int
    private var buf: [Row]
    private var idx: Int = 0
    private var filled = false

    public init(capacity: Int) {
        self.capacity = max(1, capacity)
        self.buf = Array(
            repeating: Row(t: 0, hr: nil, still: 0, drop: 0, slope: 0, propensity: 0, stateRaw: 0),
            count: self.capacity
        )
    }

    public mutating func append(hr: Double?,
                                still: Double,
                                drop: Double,
                                slope: Double,
                                propensity: Double,
                                stateRaw: Int)
    {
        let r = Row(t: Date().timeIntervalSince1970,
                    hr: hr, still: still, drop: drop, slope: slope,
                    propensity: propensity, stateRaw: stateRaw)
        buf[idx] = r
        idx = (idx + 1) % capacity
        if idx == 0 { filled = true }
    }

    public func all() -> [Row] {
        guard filled else { return Array(buf.prefix(idx)) }
        return Array(buf[idx...] + buf[..<idx])
    }

    // Optional: write CSV into the App Group so iOS can read it
    public func writeCSVToAppGroup(filename: String = "sleep_ringlog.csv") throws {
        guard let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroup.suite) else { return }
        let file = url.appendingPathComponent(filename)
        var s = "t,hr,still,drop,slope,propensity,state\n"
        for r in all() {
            s += "\(r.t),\(r.hr ?? -1),\(r.still),\(r.drop),\(r.slope),\(r.propensity),\(r.stateRaw)\n"
        }
        try s.data(using: .utf8)!.write(to: file, options: .atomic)
    }
}
