//
//  signal_filter.c
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-13.
//

#include "signal_filter.h"
#include <math.h>   // for M_PI (alpha helper)
#include <float.h>  // for FLT_EPSILON

// Clamp helper
static inline float clamp01(float x) {
    if (x < FLT_EPSILON)   return FLT_EPSILON;  // avoid 0 which would freeze y
    if (x > 1.0f)          return 1.0f;
    return x;
}

void iir1_init(iir1_t *f, float alpha) {
    if (!f) return;
    f->alpha = clamp01(alpha);
    f->y = 0.0f;
    f->initialized = 0;
}

void iir1_reset(iir1_t *f) {
    if (!f) return;
    f->initialized = 0;
    f->y = 0.0f;
}

void iir1_set_alpha(iir1_t *f, float alpha) {
    if (!f) return;
    f->alpha = clamp01(alpha);
}

float iir1_update(iir1_t *f, float x) {
    if (!f) return x;
    if (!f->initialized) {
        f->y = x;
        f->initialized = 1;
        return x;
    }
    const float a = f->alpha;
    f->y = (1.0f - a) * f->y + a * x;
    return f->y;
}

float iir1_alpha_from_cutoff(float cutoff_hz, float dt_seconds) {
    if (cutoff_hz <= 0.0f)     return 1.0f; // "no smoothing" fallback
    if (dt_seconds <= 0.0f)    return 1.0f;
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif
    const float RC = 1.0f / (2.0f * (float)M_PI * cutoff_hz);
    const float a  = dt_seconds / (RC + dt_seconds);
    return clamp01(a);
}

static inline float minf(float x, float y) { return x < y ? x : y; }
static inline float maxf(float x, float y) { return x > y ? x : y; }

// Median of 3 values (branch-light)
float median3f(float a, float b, float c) {
    const float mn = minf(a, minf(b, c));
    const float mx = maxf(a, maxf(b, c));
    return (a + b + c) - mn - mx;
}
