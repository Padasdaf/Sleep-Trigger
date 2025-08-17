//
//  WorkoutSessionManager.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

import Foundation
import HealthKit
import Combine

/// Manages a lightweight HKWorkoutSession so the app may sample HR in the background
/// while the session is active. The class is main-actor isolated, but HealthKit’s
/// delegate methods are *nonisolated*; we hop back to the main actor inside them.
@MainActor
final class WorkoutSessionManager: NSObject, ObservableObject {

    static let shared = WorkoutSessionManager()

    // MARK: - Published diagnostics
    @Published var isRunning: Bool = false
    @Published var workoutState: HKWorkoutSessionState = .notStarted
    @Published var lastError: String?

    // MARK: - Private
    private let store = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    // MARK: - Lifecycle
    /// Starts a minimal “Other” workout. Assumes HealthKit permission was granted elsewhere.
    func start() throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let cfg = HKWorkoutConfiguration()
        cfg.activityType = .other
        cfg.locationType = .unknown

        // Build session + builder
        let session = try HKWorkoutSession(healthStore: store, configuration: cfg)
        let builder  = session.associatedWorkoutBuilder()
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: store, workoutConfiguration: cfg)

        // Keep references
        self.session = session
        self.builder = builder

        // Delegates
        session.delegate = self
        builder.delegate  = self

        // Go live
        let now = Date()
        session.startActivity(with: now)
        builder.beginCollection(withStart: now) { [weak self] _, error in
            // Use self here to both update UI and avoid the “captured but not used” warning
            Task { @MainActor in
                if let error {
                    self?.lastError = error.localizedDescription
                    self?.isRunning = false
                } else {
                    self?.isRunning = true
                    self?.workoutState = session.state
                }
            }
        }
    }

    /// Ends the workout cleanly.
    func stop() {
        let now = Date()

        if let builder {
            builder.endCollection(withEnd: now) { [weak self] _, _ in
                Task { @MainActor in
                    self?.session?.stopActivity(with: now)
                    self?.session?.end()
                    self?.builder = nil
                    self?.session = nil
                    self?.isRunning = false
                    self?.workoutState = .ended
                }
            }
        } else {
            // Fallback if builder is missing
            session?.stopActivity(with: now)
            session?.end()
            builder = nil
            session = nil
            isRunning = false
            workoutState = .ended
        }
    }
}

// MARK: - HKWorkoutSessionDelegate (nonisolated callbacks)
extension WorkoutSessionManager: HKWorkoutSessionDelegate {

    /// HealthKit calls this on a background thread; hop to main before touching state.
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didFailWithError error: Error) {
        Task { @MainActor in
            self.lastError = error.localizedDescription
            self.isRunning = false
        }
    }

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didChangeTo toState: HKWorkoutSessionState,
                                    from fromState: HKWorkoutSessionState,
                                    date: Date) {
        Task { @MainActor in
            self.workoutState = toState
            if toState == .stopped || toState == .ended {
                self.isRunning = false
            }
        }
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate (nonisolated callbacks)
extension WorkoutSessionManager: HKLiveWorkoutBuilderDelegate {

    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Optional: surface events; hop to main if you update UI.
        // Task { @MainActor in /* update state/UI */ }
    }

    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                                    didCollectDataOf collectedTypes: Set<HKSampleType>) {
        // Optional: read samples; hop to main if you update UI.
        // Task { @MainActor in /* update state/UI */ }
    }
}
