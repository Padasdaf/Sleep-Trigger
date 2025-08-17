//
//  robust_stats.h
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#pragma once
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// -------- Online mean/variance (Welford) ----------
typedef struct {
  double mean;
  double m2;
  size_t n;
} rs_var_t;

static inline void rs_var_init(rs_var_t* s){ s->mean=0; s->m2=0; s->n=0; }
static inline void rs_var_update(rs_var_t* s, double x){
  s->n++; double d = x - s->mean; s->mean += d / (double)s->n; s->m2 += d*(x - s->mean);
}
static inline double rs_var_variance(const rs_var_t* s){ return (s->n>1) ? s->m2/(double)(s->n-1) : 0.0; }

// -------- EW quantile (very small-footprint) ----------
typedef struct {
  double q;     // current estimate
  double alpha; // 0..1, e.g. 0.005
  double p;     // desired quantile (0..1)
} rs_eq_t;

static inline void rs_eq_init(rs_eq_t* s, double p, double alpha, double q0){
  s->p=p; s->alpha=alpha; s->q=q0;
}
static inline void rs_eq_update(rs_eq_t* s, double x){
  double e = (x > s->q) ? 1.0 : 0.0; // sign approx
  s->q += s->alpha * ((e - s->p) > 0 ? +1.0 : -1.0);
}

// -------- Hampel filter (windowed MAD around median) ----------
#define RS_HAMPEL_MAX 15
typedef struct {
  double buf[RS_HAMPEL_MAX];
  int    k, size; // size odd <= RS_HAMPEL_MAX
  int    idx;
  int    filled;
  double last;
  double nsigma; // typically 3.0
} rs_hampel_t;

void   rs_hampel_init(rs_hampel_t* h, int windowOdd, double nsigma);
double rs_hampel_update(rs_hampel_t* h, double x);

#ifdef __cplusplus
}
#endif
