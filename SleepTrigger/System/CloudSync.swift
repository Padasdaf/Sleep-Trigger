//
//  CloudSync.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation

final class CloudSync {
    static let shared = CloudSync()
    private let kv = NSUbiquitousKeyValueStore.default

    func pushOnset(_ date: Date) {
        guard AppSettings.shared.iCloudMirrorEnabled else { return }
        kv.set(date.timeIntervalSince1970, forKey: "lastOnset")
        kv.synchronize()
    }

    func lastOnsetFromCloud() -> Date? {
        let t = kv.object(forKey: "lastOnset") as? Double
        return t.map { Date(timeIntervalSince1970: $0) }
    }
}
