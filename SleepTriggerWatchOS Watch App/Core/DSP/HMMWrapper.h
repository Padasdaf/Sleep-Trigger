//
//  HMMWrapper.h
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMMWrapper : NSObject
- (instancetype)init;
- (int)stepWithObservation:(NSInteger)obs; // 0=awake,1=drowsy,2=asleep
@end

NS_ASSUME_NONNULL_END
