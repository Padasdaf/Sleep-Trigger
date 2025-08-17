//
//  EKFWrapper.m
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#import "EKFWrapper.h"
#import "ekf.hpp"

@interface EKFWrapper () { st::KF1 _kf; }
@end

@implementation EKFWrapper
- (instancetype)initWithQ:(double)q r:(double)r x0:(double)x0 p0:(double)p0 {
  if ((self = [super init])) { _kf.set(q, r, x0, p0); }
  return self;
}
- (double)updateWithDrop:(double)drop
                   still:(double)still
                negSlope:(double)negSlope
              respQuiet:(double)respQuiet
               vlfPower:(double)vlfPower {
  double z = st::fuseFeatures(drop, still, negSlope, respQuiet, vlfPower);
  return _kf.update(z);
}
@end
