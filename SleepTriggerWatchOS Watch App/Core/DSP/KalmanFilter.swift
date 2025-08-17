//
//  KalmanFilter.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation

public final class KalmanFilter1D {
    private let core: KalmanWrapper

    public init(q: Double = 0.02,
                r: Double = 1.2,
                x0: Double = 65.0,
                p0: Double = 1.0) {
        self.core = KalmanWrapper(q: q, r: r, x0: x0, p0: p0)
    }

    @discardableResult
    public func update(_ z: Double) -> Double {
        core.update(z)
    }
}
