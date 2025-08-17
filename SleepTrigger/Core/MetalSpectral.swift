//
//  MetalSpectral.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation
import Metal

enum MetalSpectral {
    static func goertzelPowers(frames: [[Float]], freq: Float, sampleRate: Float) -> [Float] {
        guard let dev = MTLCreateSystemDefaultDevice(),
              let _ = dev.makeCommandQueue(),
              let lib = dev.makeDefaultLibrary(),
              let fn = lib.makeFunction(name: "goertzel_power"),
              let _ = try? dev.makeComputePipelineState(function: fn)
        else {
            return cpuGoertzel(frames: frames, freq: freq, sampleRate: sampleRate)
        }

        // TODO: dispatch compute work here… (kept minimal for now)
        return cpuGoertzel(frames: frames, freq: freq, sampleRate: sampleRate)
    }

    private static func cpuGoertzel(frames: [[Float]], freq: Float, sampleRate: Float) -> [Float] {
        let w = 2.0 * Float.pi * freq / sampleRate
        let coeff = 2.0 * cos(w)
        return frames.map { frame in
            var s0: Float = 0, s1: Float = 0, s2: Float = 0
            for x in frame {
                s0 = x + coeff * s1 - s2
                s2 = s1; s1 = s0
            }
            let power = s1 * s1 + s2 * s2 - coeff * s1 * s2
            return max(0, power)
        }
    }
}
