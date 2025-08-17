//
//  WatchConnectivityManager.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation
import WatchConnectivity
import WidgetKit

/// Keep `enum AppGroup { static let suite = "group.com.danielhu.sleeptrigger" }`
/// in a single file for the WATCH target (System/AppGroup.swift).
final class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    @Published var isReachable: Bool = false

    override init() {
        super.init()
        activate()
    }

    private func activate() {
        guard WCSession.isSupported() else { return }
        let s = WCSession.default
        s.delegate = self
        s.activate()
    }

    /// Called by SleepMonitor when it confirms sleep.
    func sendSleepOnset() {
        let now = Date()

        // Persist for complications
        if let gd = UserDefaults(suiteName: AppGroup.suite) {
            gd.set(now.timeIntervalSince1970, forKey: "lastOnset")
        }
        WidgetCenter.shared.reloadAllTimelines()

        guard WCSession.isSupported() else { return }
        let session = WCSession.default

        if session.isReachable {
            session.sendMessage(["sleepOnset": true], replyHandler: nil, errorHandler: nil)
        } else {
            // Fallback so the phone gets it later
            session.transferUserInfo(["sleepOnset": true])
        }
    }

    // Debug helper kept for your preview/test button.
    #if DEBUG
    func sendTestSleepOnset() { sendSleepOnset() }
    #endif

    // MARK: - WCSessionDelegate (watchOS)

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        DispatchQueue.main.async { self.isReachable = session.isReachable }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { self.isReachable = session.isReachable }
    }
}
