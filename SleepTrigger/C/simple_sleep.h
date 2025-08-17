//
//  simple_sleep.h
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-16.
//

#ifndef SIMPLE_SLEEP_H
#define SIMPLE_SLEEP_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    double mean;   // arithmetic mean
    double sd;     // standard deviation (population)
    double rmssd;  // root mean square of successive differences
} ss_stats_t;

/**
 Computes mean, sd, and RMSSD for an array of BPM samples.
 Returns {nan,nan,nan} if n < 2.
 */
ss_stats_t ss_stats(const double *samples, int n);

/**
 Produces a 0..100 sleep-likelihood score from BPM samples.
 - Uses mean HR (lower is more sleepy) and RMSSD (higher variability is more sleepy).
 - Returns -1 on insufficient data (n < 5).
 */
int ss_sleep_score(const double *samples, int n);

#ifdef __cplusplus
}
#endif
#endif /* SIMPLE_SLEEP_H */
