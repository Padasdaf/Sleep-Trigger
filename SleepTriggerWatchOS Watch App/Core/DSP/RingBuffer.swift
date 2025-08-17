//
//  RingBuffer.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation

final class RingBufferF32 {
    private var core = ringf_t(buf: nil, cap: 0, count: 0, head: 0, sum: 0)

    init(capacity: Int) {
        _ = ringf_init(&core, max(1, capacity))
    }
    deinit { ringf_free(&core) }

    @inline(__always) func push(_ x: Float) { ringf_push(&core, x) }
    @inline(__always) var mean: Float { ringf_mean(&core) }
    @inline(__always) var count: Int { Int(ringf_count(&core)) }
    func clear() { ringf_clear(&core) }
}
