//
//  HMMWrapper.m
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#import "HMMWrapper.h"
#import "hmm.hpp"

@interface HMMWrapper () { st::HMM3 _hmm; }
@end

@implementation HMMWrapper
- (instancetype)init {
  if ((self = [super init])) { _hmm.setDefault(); }
  return self;
}
- (int)stepWithObservation:(NSInteger)obs {
  int o = (int)obs;
  if (o<0) o=0; if (o>2) o=2;
  return _hmm.step(o);
}
@end
