//
//  respiration.c
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#include "respiration.h"
#include <math.h>

// bilinear transform band-pass
static void design_bpf(resp_bpf_t* f, double fs, double fl, double fh){
  double w0 = 2.0*M_PI*(sqrt(fl*fh)/fs);
  double BW = 2.0*M_PI*((fh-fl)/fs);
  double alpha = sin(w0)*sinh( (log(2)/2)*BW/sin(w0) );
  double cos0 = cos(w0);

  double b0 =   alpha;
  double b1 =   0.0;
  double b2 =  -alpha;
  double a0 =   1.0 + alpha;
  double a1 =  -2.0*cos0;
  double a2 =   1.0 - alpha;

  f->b0 = b0/a0; f->b1 = b1/a0; f->b2 = b2/a0;
  f->a1 = a1/a0; f->a2 = a2/a0;
}

void resp_init(resp_bpf_t* f, double fsHz, double fLowHz, double fHighHz){
  f->fs = fsHz; f->x1=f->x2=f->y1=f->y2=0; f->lastSign=0; f->lastCrossTime=0; f->bpm=0;
  design_bpf(f, fsHz, fLowHz, fHighHz);
}

double resp_update(resp_bpf_t* f, double x, double t){
  double y = f->b0*x + f->b1*f->x1 + f->b2*f->x2 - f->a1*f->y1 - f->a2*f->y2;
  f->x2=f->x1; f->x1=x; f->y2=f->y1; f->y1=y;

  double s = (y>=0)?+1.0:-1.0;
  if (f->lastSign < 0 && s > 0) {
    if (f->lastCrossTime>0) {
      double period = t - f->lastCrossTime;
      if (period>0.5 && period<10.0) f->bpm = 60.0/period;
    }
    f->lastCrossTime = t;
  }
  f->lastSign = s;
  return y;
}

double resp_rate_bpm(const resp_bpf_t* f){ return f->bpm; }
