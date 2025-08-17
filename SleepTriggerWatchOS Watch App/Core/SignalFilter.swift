//
//  SignalFilter.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-13.
//

import Foundation

final class IIR1 {
    private var core = iir1_t(alpha: 0, y: 0, initialized: 0)

    init(alpha: Float) { iir1_init(&core, alpha) }

    func update(_ x: Float) -> Float { iir1_update(&core, x) }
}
