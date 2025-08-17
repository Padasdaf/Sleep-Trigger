//
//  simple_sleep.c
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-16.
//

#include "simple_sleep.h"
#include <math.h>

static double clamp(double v, double lo, double hi) {
    return v < lo ? lo : (v > hi ? hi : v);
}

ss_stats_t ss_stats(const double *x, int n) {
    ss_stats_t out = {NAN, NAN, NAN};
    if (!x || n <= 0) return out;

    double sum = 0.0;
    for (int i = 0; i < n; ++i) sum += x[i];
    double mean = sum / (double)n;

    double vsum = 0.0;
    for (int i = 0; i < n; ++i) {
        double d = x[i] - mean;
        vsum += d * d;
    }
    double sd = (n > 0) ? sqrt(vsum / (double)n) : NAN;

    if (n < 2) {
        out.mean = mean; out.sd = sd; out.rmssd = NAN;
        return out;
    }

    double diff2 = 0.0;
    for (int i = 1; i < n; ++i) {
        double d = x[i] - x[i-1];
        diff2 += d * d;
    }
    double rmssd = sqrt(diff2 / (double)(n - 1));

    out.mean = mean;
    out.sd = sd;
    out.rmssd = rmssd;
    return out;
}

int ss_sleep_score(const double *x, int n) {
    if (!x || n < 5) return -1;

    ss_stats_t s = ss_stats(x, n);

    // Normalize mean HR: 40..100 bpm -> 0..1 (lower HR => closer to 1)
    double hrMin = 40.0, hrMax = 100.0;
    double hrNorm = 1.0 - clamp((s.mean - hrMin) / (hrMax - hrMin), 0.0, 1.0);

    // Normalize RMSSD: 10..80 ms -> 0..1 (higher RMSSD => closer to 1)
    // We treat BPM deltas as proxy for ms variability; scale heuristically.
    double rmssdMin = 1.0, rmssdMax = 8.0; // BPM-delta proxy range
    double rmNorm = clamp((s.rmssd - rmssdMin) / (rmssdMax - rmssdMin), 0.0, 1.0);

    // Blend weights (tweakable): HR carries more weight.
    double score01 = 0.6 * hrNorm + 0.4 * rmNorm;
    int score = (int)llround(100.0 * clamp(score01, 0.0, 1.0));
    return score;
}
