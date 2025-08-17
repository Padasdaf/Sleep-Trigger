//
//  hmm.hpp
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#pragma once
#include <array>
#include <cmath>
#include <algorithm>

namespace st {

struct HMM3 {
  // 3-state HMM (0=awake,1=drowsy,2=asleep)
  // log-domain Viterbi; online with backpointer to last only.
  std::array<double,3> logPi{};
  std::array<double,9> logA{}; // row-major [i->j]
  std::array<double,9> logE{}; // emission confusion (obs->state)
  std::array<double,3> logDelta{};
  std::array<int,3>    psi{};  // last argmax (not needed for 1-step)

  static constexpr double LOG0 = -1e30;

  static double lg(double x) { return (x<=0) ? LOG0 : std::log(x); }

  void setDefault() {
    logPi = { lg(0.7), lg(0.2), lg(0.1) };
    double A[9] = {
      0.85, 0.12, 0.03,
      0.10, 0.80, 0.10,
      0.03, 0.12, 0.85
    };
    for (int i=0;i<9;++i) logA[i]=lg(A[i]);
    double E[9] = {
      0.92, 0.06, 0.02,
      0.08, 0.86, 0.06,
      0.02, 0.08, 0.90
    };
    for (int i=0;i<9;++i) logE[i]=lg(E[i]);
    logDelta = logPi;
  }

  // obs in {0,1,2}, returns MAP state in {0,1,2}
  int step(int obs) {
    std::array<double,3> next{};
    for (int j=0;j<3;++j) {
      double best = LOG0;
      for (int i=0;i<3;++i) {
        double v = logDelta[i] + logA[i*3 + j];
        if (v > best) best = v;
      }
      next[j] = best + logE[obs*3 + j];
    }
    logDelta = next;
    // winner
    if (logDelta[0] >= logDelta[1] && logDelta[0] >= logDelta[2]) return 0;
    if (logDelta[1] >= logDelta[2]) return 1;
    return 2;
  }
};

} // namespace st
