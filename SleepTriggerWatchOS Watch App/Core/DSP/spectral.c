//
//  spectral.c
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#include "spectral.h"
#include <math.h>

void goertzel_init(goertzel_t* g, double fs, double f, int N){
  double k = 0.5 + (N * f / fs);
  double w = 2.0*M_PI * k / (double)N;
  g->coeff = 2.0*cos(w);
  g->s1 = g->s2 = 0.0;
  g->norm = (double)N;
}

void goertzel_reset(goertzel_t* g){ g->s1=g->s2=0.0; }

void goertzel_push(goertzel_t* g, double x){
  double s0 = x + g->coeff*g->s1 - g->s2;
  g->s2 = g->s1; g->s1 = s0;
}

double goertzel_power(goertzel_t* g){
  double p = g->s1*g->s1 + g->s2*g->s2 - g->coeff*g->s1*g->s2;
  goertzel_reset(g);
  return p / g->norm;
}
