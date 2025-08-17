//
//  PerfBridge.h
//  SleepTriggerMac
//
//  Created by Daniel Hu on 2025-08-15.
//

#pragma once
#ifdef __cplusplus
extern "C" {
#endif

float cpp_dot_f32(const float* a, const float* b, int n);
float cpp_ema_f32(const float* x, int n, float alpha);

#ifdef __cplusplus
}
#endif
