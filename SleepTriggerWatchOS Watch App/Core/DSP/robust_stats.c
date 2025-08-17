//
//  robust_stats.c
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#include "robust_stats.h"
#include <string.h>
#include <math.h>
#include <stdlib.h>

static int cmpd(const void* a, const void* b){
    double da = *(const double*)a, db = *(const double*)b;
    return (da<db)?-1:((da>db)?+1:0);
}

void rs_hampel_init(rs_hampel_t* h, int windowOdd, double nsigma){
  if (windowOdd < 3) windowOdd = 3;
  if (windowOdd > RS_HAMPEL_MAX) windowOdd = RS_HAMPEL_MAX;
  if ((windowOdd % 2) == 0) windowOdd -= 1;
  memset(h, 0, sizeof(*h));
  h->size = windowOdd;
  h->nsigma = nsigma;
}

double rs_hampel_update(rs_hampel_t* h, double x){
  h->buf[h->idx] = x;
  h->idx = (h->idx + 1) % h->size;
  if (h->filled < h->size) h->filled++;

  h->last = x;

  // compute median & MAD on copy (small windows only)
  int n = h->filled;
  double tmp[RS_HAMPEL_MAX];
  for (int i=0;i<n;++i) tmp[i]=h->buf[i];
  qsort(tmp, n, sizeof(double), cmpd);
  double median = tmp[n/2];

  for (int i=0;i<n;++i) tmp[i] = fabs(h->buf[i] - median);
  qsort(tmp, n, sizeof(double), cmpd);
  double mad = tmp[n/2];
  double sigma = 1.4826 * mad; // Gauss approx

  if (sigma <= 1e-9) return x; // not enough variation

  if (fabs(x - median) > h->nsigma * sigma) {
    // replace outlier by median
    return median;
  }
  return x;
}
