//
//  Goertzel.metal
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-14.
//

#include <metal_stdlib>
using namespace metal;

// Each thread processes one frame of N samples at frequency bin k
kernel void goertzel_power(const device float* inSamples      [[ buffer(0) ]],
                           const device uint2*  framesOffsets [[ buffer(1) ]],
                           constant float&      coeff         [[ buffer(2) ]],
                           constant uint&       N             [[ buffer(3) ]],
                           device float*        outPowers     [[ buffer(4) ]],
                           uint tid [[thread_position_in_grid]]) {
    uint2 off = framesOffsets[tid];
    uint base = off.x;
    float s0 = 0.0, s1 = 0.0, s2 = 0.0;
    for (uint n = 0; n < N; ++n) {
        float x = inSamples[base + n];
        s0 = x + coeff * s1 - s2;
        s2 = s1;
        s1 = s0;
    }
    float power = s1*s1 + s2*s2 - coeff*s1*s2;
    outPowers[tid] = power;
}
