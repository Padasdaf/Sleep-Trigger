//
//  tinyml_motion.h
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#pragma once
#ifdef __cplusplus
extern "C" {
#endif

// Inputs are normalized features (0..1) such as stillness mean and variance.
// Returns 0=still, 1=fidget, 2=active.
static inline int tiny_motion_classify(double stillMean, double stillVar){
  if (stillMean > 0.85 && stillVar < 0.02) return 0;        // very still
  if (stillMean > 0.60 && stillVar < 0.08) return 1;        // fidget
  return 2;                                                 // likely active/walking
}

#ifdef __cplusplus
}
#endif
