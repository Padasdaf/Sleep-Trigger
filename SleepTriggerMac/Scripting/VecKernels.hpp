//
//  VecKernels.hpp
//  SleepTriggerMac
//
//  Created by Daniel Hu on 2025-08-15.
//

#pragma once
#include <cstddef>

namespace stk {

// Simple, portable C++ implementations (no SIMD to keep it portable).
float dot_f32(const float* a, const float* b, std::size_t n);
float ema_f32(const float* x, std::size_t n, float alpha);

} // namespace stk
