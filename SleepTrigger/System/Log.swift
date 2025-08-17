//
//  Log.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-15.
//

import os

enum Log {
    static let detect  = Logger(subsystem: "com.danielhu.SleepTrigger", category: "detect")
    static let wc      = Logger(subsystem: "com.danielhu.SleepTrigger", category: "wc")
    static let bridge  = Logger(subsystem: "com.danielhu.SleepTrigger", category: "bridge")
    static let widgets = Logger(subsystem: "com.danielhu.SleepTrigger", category: "widgets")
}
