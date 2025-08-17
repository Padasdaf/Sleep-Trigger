//
//  duty_control.h
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#pragma once
#ifdef __cplusplus
extern "C" {
#endif

typedef enum { DC_AWAKE=0, DC_DROWSY=1, DC_ASLEEP=2 } dc_state_t;

typedef struct {
  double tickFast; // seconds (drowsy)
  double tickSlow; // seconds (stable awake/asleep)
  double lastTickTime;
  dc_state_t lastState;
} duty_ctrl_t;

static inline void dc_init(duty_ctrl_t* c, double tickFast, double tickSlow){
  c->tickFast=tickFast; c->tickSlow=tickSlow; c->lastTickTime=0; c->lastState=DC_AWAKE;
}

// returns recommended next interval in seconds given current state
static inline double dc_next_interval(duty_ctrl_t* c, dc_state_t st){
  double dt = (st==DC_DROWSY) ? c->tickFast : c->tickSlow;
  c->lastState = st;
  return dt;
}

#ifdef __cplusplus
}
#endif
