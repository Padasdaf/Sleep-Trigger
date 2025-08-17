//
//  signal_filter.h
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-13.
//

#ifndef SIGNAL_FILTER_H
#define SIGNAL_FILTER_H

#ifdef __cplusplus
extern "C" {
#endif

/// One-pole IIR (exponential moving average)
/// y[n] = (1 - alpha) * y[n-1] + alpha * x[n]
/// alpha in (0,1]; higher = more responsive, lower = smoother.
typedef struct {
    float alpha;       // 0..1 (clamped internally)
    float y;
    int   initialized;
} iir1_t;

/// Initialize with explicit alpha (0 < alpha <= 1). If out of range, clamps.
void  iir1_init(iir1_t *f, float alpha);

/// Reset the filter state to "uninitialized" (next update will set y=x).
void  iir1_reset(iir1_t *f);

/// Change alpha at runtime (clamped to sensible range).
void  iir1_set_alpha(iir1_t *f, float alpha);

/// Single update step. If uninitialized, seeds y with x and returns x.
float iir1_update(iir1_t *f, float x);

/// Utility: compute alpha from a desired low-pass cutoff (Hz) and sample
/// period dt (seconds). Uses RC = 1 / (2π fc), alpha = dt / (RC + dt).
float iir1_alpha_from_cutoff(float cutoff_hz, float dt_seconds);

/// Optional tiny helper: 3-sample median (useful for spike rejection).
float median3f(float a, float b, float c);

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* SIGNAL_FILTER_H */
