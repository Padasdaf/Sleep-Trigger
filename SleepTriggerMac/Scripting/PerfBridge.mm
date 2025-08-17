//
//  PerfBridge.m
//  SleepTriggerMac
//
//  Created by Daniel Hu on 2025-08-15.
//

#import "PerfBridge.h"
#import "VecKernels.hpp"

float cpp_dot_f32(const float* a, const float* b, int n) {
    return stk::dot_f32(a, b, (size_t)n);
}
float cpp_ema_f32(const float* x, int n, float alpha) {
    return stk::ema_f32(x, (size_t)n, alpha);
}
