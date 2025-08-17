//
//  ringlog.h
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#pragma once
#include <stdint.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  FILE* fp;
  uint32_t capacity; // number of records
  uint32_t recSize;
} rlog_t;

typedef struct __attribute__((packed)) {
  double t;        // seconds since reference
  float  hr;       // bpm
  float  still;    // 0..1
  float  prop;     // propensity 0..1
  uint8_t state;   // 0/1/2
} rlog_rec_t;

int  rlog_open(rlog_t* r, const char* path, uint32_t capacity);
int  rlog_write(rlog_t* r, const rlog_rec_t* rec);
void rlog_close(rlog_t* r);

#ifdef __cplusplus
}
#endif
