//
//  KalmanWrapper.h
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#import <Foundation/Foundation.h>

NS_SWIFT_NAME(KalmanWrapper)
@interface KalmanWrapper : NSObject

- (instancetype)initWithQ:(double)q
                         R:(double)r
                        X0:(double)x0
                        P0:(double)p0 NS_DESIGNATED_INITIALIZER;

- (double)update:(double)z;

@end
