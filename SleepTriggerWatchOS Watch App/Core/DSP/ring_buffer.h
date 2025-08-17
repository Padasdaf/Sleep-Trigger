//
//  ring_buffer.h
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#ifndef RING_BUFFER_H
#define RING_BUFFER_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    float *buf;
    size_t cap;
    size_t count;
    size_t head;   // next write index
    float  sum;    // running sum for O(1) mean
} ringf_t;

// Return 0 on success, nonzero on allocation failure/invalid capacity.
int  ringf_init(ringf_t *r, size_t capacity);
void ringf_free(ringf_t *r);
void ringf_clear(ringf_t *r);
void ringf_push(ringf_t *r, float x);  // overwrites oldest when full
size_t ringf_count(const ringf_t *r);
size_t ringf_capacity(const ringf_t *r);
float ringf_mean(const ringf_t *r);

#ifdef __cplusplus
}
#endif
#endif /* RING_BUFFER_H */
