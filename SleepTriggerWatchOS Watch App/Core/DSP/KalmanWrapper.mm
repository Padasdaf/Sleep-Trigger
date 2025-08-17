//
//  KalmanWrapper.m
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#import "KalmanWrapper.h"
extern "C" {
#import "kalman.h"   // C API
}

@interface KalmanWrapper () {
    Kalman1D _kf;    // store C struct by value
}
@end

@implementation KalmanWrapper

- (instancetype)init {
    // Default params if somebody calls plain init
    return [self initWithQ:0.02 R:1.2 X0:65.0 P0:1.0];
}

- (instancetype)initWithQ:(double)q R:(double)r X0:(double)x0 P0:(double)p0 {
    if ((self = [super init])) {
        kalman1d_init(&_kf, q, r, x0, p0);
    }
    return self;
}

- (double)update:(double)z {
    return kalman1d_update(&_kf, z);
}

@end
