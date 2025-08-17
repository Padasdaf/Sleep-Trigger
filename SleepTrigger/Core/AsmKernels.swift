//
//  AsmKernels.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation
#if canImport(Accelerate)
import Accelerate
#endif

// Declare the assembly routine only on real watchOS hardware.
// (No symbol gets emitted on iOS/macOS or on the watch simulator.)
#if os(watchOS) && !targetEnvironment(simulator)
@_silgen_name("dot_f32_accel")
private func dot_f32_accel(
    _ a: UnsafePointer<Float>?,
    _ b: UnsafePointer<Float>?,
    _ n: Int32
) -> Float
#endif

/// Swift-friendly wrapper around the (optional) assembly dot-product.
enum AsmKernels {

    /// Dot product of two `Float` vectors.
    /// Uses NEON assembly on real Apple Watch hardware; otherwise falls back.
    static func dot(_ a: [Float], _ b: [Float]) -> Float {
        precondition(a.count == b.count, "Mismatched lengths")

        // --- Fast path: assembly on real watchOS device ---
        #if os(watchOS) && !targetEnvironment(simulator)
        return a.withUnsafeBufferPointer { ap in
            b.withUnsafeBufferPointer { bp in
                guard let pa = ap.baseAddress, let pb = bp.baseAddress else { return 0 }
                return dot_f32_accel(pa, pb, Int32(a.count))
            }
        }
        #else
        // --- Fallbacks for every other platform ---
        #if canImport(Accelerate)
        var result: Float = 0
        vDSP_dotpr(a, 1, b, 1, &result, vDSP_Length(a.count))
        return result
        #else
        var s: Float = 0
        for i in 0..<a.count { s += a[i] * b[i] }
        return s
        #endif
        #endif
    }
}
