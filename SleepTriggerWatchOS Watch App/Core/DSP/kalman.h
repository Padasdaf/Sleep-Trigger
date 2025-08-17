//
//  kalman.h
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#ifndef KALMAN_H
#define KALMAN_H

#ifdef __cplusplus
extern "C" {
#endif

// Simple 1D Kalman filter state
typedef struct {
    double q;      // process noise variance
    double r;      // measurement noise variance
    double x;      // estimate
    double p;      // estimate covariance
    double k;      // Kalman gain (for inspection)
    int    initialized;
} Kalman1D;

// Initialize filter with parameters and initial state.
void   kalman1d_init(Kalman1D *kf, double q, double r, double x0, double p0);

// One update step with measurement z. Returns new estimate x.
double kalman1d_update(Kalman1D *kf, double z);

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* KALMAN_H */
