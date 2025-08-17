//
//  asm_compat.h
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#ifndef ASM_COMPAT_H
#define ASM_COMPAT_H
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// Returns dot(a,b,n) as float
float dot_f32_accel(const float* a, const float* b, size_t n);

#ifdef __cplusplus
}
#endif
#endif
