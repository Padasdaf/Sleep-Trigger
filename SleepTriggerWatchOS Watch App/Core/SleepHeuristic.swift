//
//  SleepHeuristic.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation
import Combine

final class SleepHeuristic: ObservableObject {
    // Tunables
    var baselineWindow: TimeInterval = 5 * 60    // 5 min to estimate awake HR
    var dropPercent: Double = 0.12               // 12% below baseline
    var minStillSeconds: TimeInterval = 180      // 3 min stillness

    // State
    private var baselineValues: [(Date, Double)] = []
    private var lastStillStart: Date?
    private var cancellables = Set<AnyCancellable>()

    // Inputs
    @Published var latestBPM: Double?
    @Published var isStill: Bool = false

    // Output
    @Published private(set) var didDetectSleep = false

    init() {
        $isStill
            .sink { [weak self] still in
                guard let self else { return }
                if still {
                    if self.lastStillStart == nil { self.lastStillStart = Date() }
                } else {
                    self.lastStillStart = nil
                }
            }
            .store(in: &cancellables)

        $latestBPM
            .compactMap { $0 }
            .sink { [weak self] bpm in
                self?.ingestHR(bpm)
            }
            .store(in: &cancellables)
    }

    private func ingestHR(_ bpm: Double) {
        let now = Date()
        // maintain baseline window
        baselineValues.append((now, bpm))
        let cutoff = now.addingTimeInterval(-baselineWindow)
        baselineValues.removeAll { $0.0 < cutoff }

        // need enough data to compute a baseline
        guard baselineValues.count >= 15 else { return }
        let baseline = baselineValues.map(\.1).reduce(0,+) / Double(baselineValues.count)

        let hrBelow = bpm <= baseline * (1.0 - dropPercent)
        let stillLongEnough: Bool = {
            if let s = lastStillStart { return Date().timeIntervalSince(s) >= minStillSeconds }
            return false
        }()

        if hrBelow && stillLongEnough {
            didDetectSleep = true
        }
    }

    func reset() {
        baselineValues.removeAll()
        lastStillStart = nil
        didDetectSleep = false
    }
}
