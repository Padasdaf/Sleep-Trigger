//
//  FeatureFlags.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-15.
//

import Foundation

/// Optional, low-risk toggles. Defaults keep current behavior.
enum FeatureFlags {
    #if DEBUG
    static var developerMode = true
    #else
    static var developerMode = false
    #endif

    /// Use reliable WC transferUserInfo for watch→phone when reachable is false.
    static var useReliableWC = false

    /// Ignore mirrored iCloud KVS onsets that are duplicates (±0.25s).
    static var useKVSDedup = true

    /// Hints for diagnostics only (doesn’t change the pipeline).
    static var useMetal = false
    static var useAsm   = true
}
