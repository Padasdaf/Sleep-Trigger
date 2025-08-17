//
//  asm_compat.c
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#include "asm_compat.h"

static inline float dot_f32_c(const float* a, const float* b, size_t n) {
    float acc = 0.f;
    for (size_t i=0; i<n; ++i) acc += a[i] * b[i];
    return acc;
}

// Declaration for the asm symbol (only exists on arm64 devices)
#if defined(__aarch64__)
extern float neon_dot_f32(const float* a, const float* b, size_t n);
#endif

float dot_f32_accel(const float* a, const float* b, size_t n) {
#if defined(__aarch64__) && !TARGET_OS_SIMULATOR
    return neon_dot_f32(a, b, n);
#else
    return dot_f32_c(a, b, n);
#endif
}
