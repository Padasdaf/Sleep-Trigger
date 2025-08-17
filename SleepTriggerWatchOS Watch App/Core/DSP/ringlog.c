//
//  ringlog.c
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#include "ringlog.h"
#include <string.h>

int rlog_open(rlog_t* r, const char* path, uint32_t cap) {
  r->fp = fopen(path, "wb+");
  if (!r->fp) return -1;
  r->capacity = cap;
  r->recSize  = sizeof(rlog_rec_t);
  return 0;
}

int rlog_write(rlog_t* r, const rlog_rec_t* rec) {
  if (!r->fp) return -1;

  // write one record
  if (fwrite(rec, r->recSize, 1, r->fp) != 1) return -1;

  // wrap to start when file reaches capacity
  long size = ftell(r->fp);
  long max  = (long)r->capacity * (long)r->recSize;
  if (size >= max) {
    fflush(r->fp);
    fseek(r->fp, 0L, SEEK_SET);
  } else {
    fflush(r->fp);
  }
  return 0;
}

void rlog_close(rlog_t* r) {
  if (r->fp) fclose(r->fp);
  r->fp = NULL;
}
