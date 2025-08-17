//
//  HeartRateStream.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation
import HealthKit

final class HeartRateStream: NSObject, ObservableObject, HKLiveWorkoutBuilderDelegate, HKWorkoutSessionDelegate {
    private let store: HKHealthStore
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    @Published var latestBPM: Double?

    init(store: HKHealthStore) {
        self.store = store
        super.init()
    }

    func start() throws {
        let config = HKWorkoutConfiguration()
        config.activityType = .mindAndBody
        config.locationType = .indoor

        let session = try HKWorkoutSession(healthStore: store, configuration: config)
        let builder  = session.associatedWorkoutBuilder()

        session.delegate = self
        builder.delegate = self
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: store, workoutConfiguration: config)

        self.session = session
        self.builder = builder

        session.startActivity(with: Date())
        builder.beginCollection(withStart: Date()) { _, _ in }
    }

    func stop() {
        session?.end()
        builder?.endCollection(withEnd: Date()) { _, _ in }
        session = nil
        builder  = nil
    }

    // MARK: HKLiveWorkoutBuilderDelegate
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf types: Set<HKSampleType>) {
        guard let hrType = HKObjectType.quantityType(forIdentifier: .heartRate),
              types.contains(hrType),
              let stats = workoutBuilder.statistics(for: hrType) else { return }

        let bpmUnit = HKUnit(from: "count/min")
        if let val = stats.mostRecentQuantity()?.doubleValue(for: bpmUnit) {
            DispatchQueue.main.async { self.latestBPM = val }
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}

    // MARK: HKWorkoutSessionDelegate
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {}
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {}
}
