//
//  ScriptRunner.m
//  SleepTriggerMac
//
//  Created by Daniel Hu on 2025-08-14.
//

#import "ScriptRunner.h"
@import AppKit;

@implementation ScriptRunner
+ (instancetype)shared { static ScriptRunner *s; static dispatch_once_t once; dispatch_once(&once, ^{ s = [ScriptRunner new]; }); return s; }

- (void)pauseMedia {
    NSString *src =
    @"tell application \"Music\" to pause\n"
     "tell application \"Podcasts\" to pause\n";
    [self runAppleScriptSource:src];
}

- (void)enableFocus {
    // Example: turn on 'Sleep' focus via shell (requires permissions on first run)
    // You can replace with better Focus APIs or Automator/Shortcuts if preferred.
    NSString *src =
    @"tell application \"System Events\"\n"
     "    tell application process \"ControlCenter\"\n"
     "        -- placeholder; Focus scripting varies by macOS version\n"
     "    end tell\n"
     "end tell\n";
    // For demo, just beep so you can see execution
    NSBeep();
    [self runAppleScriptSource:src];
}

- (void)runAppleScriptSource:(NSString *)source {
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    NSDictionary *err = nil;
    [script executeAndReturnError:&err];
    if (err) {
        NSLog(@"AppleScript error: %@", err);
    }
}
@end
