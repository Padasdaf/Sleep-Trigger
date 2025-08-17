//
//  ekf.hpp
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#pragma once
#include <algorithm>
namespace st {

struct KF1 {
  double x{0.0};   // state (sleep propensity 0..1)
  double P{1.0};   // covariance
  double q{0.01};  // process noise
  double r{0.10};  // measurement noise

  void set(double q_, double r_, double x0=0.0, double p0=1.0) {
    q=q_; r=r_; x=x0; P=p0;
  }

  // z should be 0..1 fused measurement from features
  double update(double z) {
    // predict
    P += q;
    // update
    double K = P / (P + r);
    x = x + K*(z - x);
    P = (1.0 - K)*P;
    if (x<0) x=0; if (x>1) x=1;
    return x;
  }
};

inline double fuseFeatures(double drop, double still, double negSlope,
                           double respQuiet, double vlfPower) {
  // Normalize/clip to 0..1 and fuse with hand-tuned weights
  auto clip = [](double v){ return v<0?0:(v>1?1:v); };
  drop      = clip(drop);
  still     = clip(still);
  negSlope  = clip(negSlope);
  respQuiet = clip(respQuiet);
  vlfPower  = clip(vlfPower);
  // weights sum ~1
  return 0.35*drop + 0.30*still + 0.15*negSlope + 0.10*respQuiet + 0.10*vlfPower;
}

} // namespace st
