//
//  respiration.h
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#pragma once
#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  // Simple biquad (Direct Form I)
  double b0,b1,b2,a1,a2;
  double x1,x2,y1,y2;
  double fs; // Hz
  double lastSign;
  double lastCrossTime; // seconds
  double bpm; // last estimate
} resp_bpf_t;

void  resp_init(resp_bpf_t* f, double fsHz, double fLowHz, double fHighHz);
double resp_update(resp_bpf_t* f, double x, double tSeconds); // returns bandpassed signal
double resp_rate_bpm(const resp_bpf_t* f); // last estimated rate

#ifdef __cplusplus
}
#endif
