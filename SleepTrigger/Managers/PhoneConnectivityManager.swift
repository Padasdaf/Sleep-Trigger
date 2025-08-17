//
//  PhoneConnectivityManager.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation
import WatchConnectivity
import os.log
import UserNotifications
import WidgetKit
import Combine

private let log = Logger(subsystem: "com.danielhu.SleepTrigger", category: "WC")

final class PhoneConnectivityManager: NSObject, ObservableObject {

    static let shared = PhoneConnectivityManager()

    // Published diagnostics/state (read from UI on main actor)
    @Published var isReachable: Bool = false
    @Published var isPaired: Bool = false
    @Published var isWatchAppInstalled: Bool = false
    @Published var activationState: WCSessionActivationState = .notActivated
    @Published var lastOnsetAt: Date? = nil
    @Published var lastMessageDate: Date? = nil
    @Published var lastError: String? = nil

    // MARK: Lifecycle
    func start() {
        guard WCSession.isSupported() else {
            log.error("WCSession not supported on this device.")
            return
        }
        let s = WCSession.default
        s.delegate = self
        s.activate()

        // Ask for local-notification permission on main actor.
        Task { @MainActor in
            NotificationManager.shared.requestPermissionIfNeeded()
        }

        refreshSessionMetrics(s)
    }

    // MARK: Settings sync (optional)
    func syncSettingsToWatch() {
        guard WCSession.isSupported() else { return }
        let s = WCSession.default
        let settings = AppSettings.shared
        var ctx: [String: Any] = [
            "armed": settings.armed,
            "napModeEnabled": settings.napModeEnabled,
            "gatingEnabled": settings.gatingEnabled,
            "gateStartHour": settings.gateStartHour,
            "gateEndHour": settings.gateEndHour,
            "holdSecondsBeforeRun": settings.holdSecondsBeforeRun
        ]
        if !settings.shortcutName.isEmpty { ctx["shortcutName"] = settings.shortcutName }

        do {
            try s.updateApplicationContext(ctx)
            log.debug("Pushed applicationContext to watch: \(ctx, privacy: .public)")
        } catch {
            log.error("updateApplicationContext error: \(error.localizedDescription)")
            DispatchQueue.main.async { self.lastError = error.localizedDescription }
        }
    }

    func pingWatch() {
        guard WCSession.isSupported(), WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["ping": Date().timeIntervalSince1970],
                                      replyHandler: { reply in
                                          log.debug("Ping reply: \(reply, privacy: .public)")
                                      },
                                      errorHandler: { error in
                                          log.error("Ping error: \(error.localizedDescription)")
                                          DispatchQueue.main.async { self.lastError = error.localizedDescription }
                                      })
    }

    // MARK: - Private (main-actor work funnel)

    @MainActor
    private func processOnset(now: Date, source: String) {
        self.lastOnsetAt = now
        PhoneHistoryStore.shared.append(date: now)

        if let gd = UserDefaults(suiteName: AppGroupID.suite) {
            gd.set(now.timeIntervalSince1970, forKey: "lastOnset")
        }
        WidgetCenter.shared.reloadAllTimelines()

        NotificationManager.shared.notifySleepDetected()
        SleepEventBridge.shared.handleSleepDetected(now: now)
        SleepEventBridge.shared.publishAppEventIfAvailable()

        log.debug("Processed onset from \(source, privacy: .public) at \(now, privacy: .public)")
    }

    private func refreshSessionMetrics(_ s: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = s.isReachable
            self.isPaired = s.isPaired
            self.isWatchAppInstalled = s.isWatchAppInstalled
        }
    }
}

// MARK: - WCSessionDelegate (explicitly nonisolated)

extension PhoneConnectivityManager: WCSessionDelegate {

    nonisolated func session(_ session: WCSession,
                             activationDidCompleteWith activationState: WCSessionActivationState,
                             error: (any Error)?) {
        if let error {
            log.error("WC activation error: \(error.localizedDescription, privacy: .public)")
            Task { @MainActor [weak self] in self?.lastError = error.localizedDescription }
        } else {
            log.debug("WC activated with state: \(activationState.rawValue, privacy: .public)")
        }
        Task { @MainActor [weak self] in
            self?.activationState = activationState
            self?.refreshSessionMetrics(session)
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        log.debug("WC session did become inactive")
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        log.debug("WC session did deactivate, reactivating…")
        WCSession.default.activate()
    }

    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor [weak self] in self?.refreshSessionMetrics(session) }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor [weak self] in self?.isReachable = session.isReachable }
    }

    /// Foreground message from the Watch.
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task { @MainActor [weak self] in self?.lastMessageDate = Date() }

        // 1) Watch forwarded a history row
        if let add = message["historyAdd"] as? [String: Any] {
            Task { @MainActor in
                PhoneHistoryStore.shared.importFromWatchPayload(add)
            }
            return
        }

        // 2) Normal detection ping
        guard let onset = message["sleepOnset"] as? Bool, onset else { return }
        Task { @MainActor [weak self] in
            self?.processOnset(now: Date(), source: "didReceiveMessage")
        }
    }

    /// Reliable background path (watch queued transferUserInfo).
    nonisolated func session(_ session: WCSession,
                             didReceiveUserInfo userInfo: [String : Any] = [:]) {
        guard let ts = userInfo["sleepOnsetTS"] as? Double else { return }
        let date = Date(timeIntervalSince1970: ts)
        Task { @MainActor [weak self] in
            self?.processOnset(now: date, source: "transferUserInfo")
        }
    }
}
