//
//  kalman.c
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#include "kalman.h"

void kalman1d_init(Kalman1D *kf, double q, double r, double x0, double p0) {
    if (!kf) return;
    kf->q = q;
    kf->r = r;
    kf->x = x0;
    kf->p = p0;
    kf->k = 0.0;
    kf->initialized = 1;
}

double kalman1d_update(Kalman1D *kf, double z) {
    if (!kf) return z;
    if (!kf->initialized) {
        kalman1d_init(kf, kf->q, kf->r, z, 1.0);
        return z;
    }
    // Time update (prediction)
    kf->p = kf->p + kf->q;

    // Measurement update
    double denom = kf->p + kf->r;
    if (denom <= 0.0) denom = kf->r;     // guard
    kf->k = kf->p / denom;               // Kalman gain
    kf->x = kf->x + kf->k * (z - kf->x); // new estimate
    kf->p = (1.0 - kf->k) * kf->p;       // new covariance
    return kf->x;
}
