//
//  spectral.h
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#pragma once
#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  double coeff, s1, s2;
  double norm;
} goertzel_t;

void   goertzel_init(goertzel_t* g, double fs, double fTarget, int N);
void   goertzel_reset(goertzel_t* g);
void   goertzel_push(goertzel_t* g, double x);
double goertzel_power(goertzel_t* g); // call after N pushes; then reset

#ifdef __cplusplus
}
#endif
