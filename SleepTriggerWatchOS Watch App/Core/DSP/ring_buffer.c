//
//  ring_buffer.c
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#include "ring_buffer.h"
#include <stdlib.h>

int ringf_init(ringf_t *r, size_t capacity) {
    if (!r || capacity == 0) return -1;
    r->buf = (float *)calloc(capacity, sizeof(float));
    if (!r->buf) return -2;
    r->cap = capacity;
    r->count = 0;
    r->head = 0;
    r->sum = 0.0f;
    return 0;
}

void ringf_free(ringf_t *r) {
    if (!r) return;
    free(r->buf);
    r->buf = NULL;
    r->cap = r->count = r->head = 0;
    r->sum = 0.0f;
}

void ringf_clear(ringf_t *r) {
    if (!r || !r->buf) return;
    for (size_t i = 0; i < r->cap; ++i) r->buf[i] = 0.0f;
    r->count = 0;
    r->head = 0;
    r->sum = 0.0f;
}

void ringf_push(ringf_t *r, float x) {
    if (!r || !r->buf) return;

    if (r->count < r->cap) {
        r->buf[r->head] = x;
        r->sum += x;
        r->head = (r->head + 1) % r->cap;
        r->count++;
    } else {
        // Overwrite oldest
        size_t tail = r->head; // when full, head == oldest index to replace
        float old = r->buf[tail];
        r->buf[tail] = x;
        r->sum += (x - old);
        r->head = (r->head + 1) % r->cap;
    }
}

size_t ringf_count(const ringf_t *r)     { return r ? r->count : 0; }
size_t ringf_capacity(const ringf_t *r)  { return r ? r->cap   : 0; }

float ringf_mean(const ringf_t *r) {
    if (!r || r->count == 0) return 0.0f;
    return r->sum / (float)r->count;
}
