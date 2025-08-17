//
//  ScriptRunner.h
//  SleepTriggerMac
//
//  Created by Daniel Hu on 2025-08-14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface ScriptRunner : NSObject
+ (instancetype)shared;
- (void)pauseMedia;
- (void)enableFocus;
@end
NS_ASSUME_NONNULL_END
