//
//  ScriptRunner.swift
//  SleepTriggerMac
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation
import AppKit

final class ScriptRunner: NSObject {
    static let shared = ScriptRunner()
    private override init() {}

    func pauseMedia() {
        runAppleScript("tell application \"Music\" to pause")
        runAppleScript("tell application \"TV\" to pause")
        runAppleScript("tell application \"Spotify\" to pause")
    }

    func enableFocus() {
        // Example: toggle Do Not Disturb (Focus) via Shortcuts if you have one named "Enable Sleep Focus"
        if let url = URL(string: "shortcuts://run-shortcut?name=\("Enable Sleep Focus".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)") {
            NSWorkspace.shared.open(url)
        }
    }

    private func runAppleScript(_ source: String) {
        if let script = NSAppleScript(source: source) {
            var err: NSDictionary?
            _ = script.executeAndReturnError(&err)
            if let err { NSLog("AppleScript error: \(err)") }
        }
    }
}
