//
//  VecKernels.cpp
//  SleepTriggerMac
//
//  Created by Daniel Hu on 2025-08-15.
//

#include "VecKernels.hpp"

namespace stk {

float dot_f32(const float* a, const float* b, std::size_t n) {
    float s = 0.0f;
    for (std::size_t i = 0; i < n; ++i) s += a[i] * b[i];
    return s;
}

float ema_f32(const float* x, std::size_t n, float alpha) {
    if (!x || n == 0) return 0.0f;
    float y = x[0];
    for (std::size_t i = 1; i < n; ++i) y = alpha * x[i] + (1.0f - alpha) * y;
    return y;
}

} // namespace stk
