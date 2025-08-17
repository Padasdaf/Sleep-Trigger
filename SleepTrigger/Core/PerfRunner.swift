//
//  PerfRunner.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-15.
//

import Foundation
#if canImport(Metal)
import Metal
#endif

enum PerfRunner {
    static func swiftDot(_ a: [Float], _ b: [Float]) -> Float {
        precondition(a.count == b.count)
        var s: Float = 0
        for i in 0..<a.count { s += a[i] * b[i] }
        return s
    }

    static func time<T>(_ label: String, runs: Int = 3, _ body: () -> T) -> (T, Double) {
        var best = Double.greatestFiniteMagnitude
        var result: T! = nil
        for _ in 0..<runs {
            let t0 = CFAbsoluteTimeGetCurrent()
            result = body()
            let dt = (CFAbsoluteTimeGetCurrent() - t0) * 1000
            best = min(best, dt)
        }
        return (result, best)
    }

    #if canImport(Metal)
    // Placeholder: we keep Metal out of the hot path unless you want to write a dot shader.
    // For the demo we just return nil; you already have MetalSpectral for DSP demos.
    static func metalDot(_ a: [Float], _ b: [Float]) -> (Float, Double)? { nil }
    #endif
}
