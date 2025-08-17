//
//  neon_dot.S
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

// neon_dot.S — AArch64 / arm64_32 NEON dot product
// float dot_f32_accel(const float* a, const float* b, int n)
//
// x0=a, x1=b, w2=n   → returns s0

    .text
    .align  2
    .globl  _dot_f32_accel
_dot_f32_accel:
    // acc = 0 in v8
    eor     v8.16b, v8.16b, v8.16b

// Main loop: 4 floats per step
1:
    cmp     w2, #4
    blt     2f

    ld1     {v0.4s}, [x0], #16
    ld1     {v1.4s}, [x1], #16
    fmla    v8.4s, v0.4s, v1.4s     // acc += a*b

    sub     w2, w2, #4
    b       1b

// Tail: 1–3 remaining floats
2:
    cbz     w2, 3f
    mov     w3, w2
4:
    ldr     s0, [x0], #4
    ldr     s1, [x1], #4
    fmla    s8, s0, s1
    subs    w3, w3, #1
    b.ne    4b

// Reduce and return
3:
    faddv   s0, v8.4s               // s0 = sum(v8)
    ret
