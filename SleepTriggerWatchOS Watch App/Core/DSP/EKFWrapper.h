//
//  EKFWrapper.h
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EKFWrapper : NSObject
- (instancetype)initWithQ:(double)q r:(double)r x0:(double)x0 p0:(double)p0;
- (double)updateWithDrop:(double)drop
                  still:(double)still
               negSlope:(double)negSlope
             respQuiet:(double)respQuiet
              vlfPower:(double)vlfPower; // returns propensity 0..1
@end

NS_ASSUME_NONNULL_END
