//
//  HealthKitManager.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import HealthKit

/// Minimal, focused HealthKit surface used by Diagnostics & history previews.
/// Keep this file in the **iOS target only**.
enum HealthKitManager {

    // Shared store
    static let store = HKHealthStore()

    // MARK: - Authorization

    /// Requests read authorization for Heart Rate and Sleep Analysis, if available.
    static func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let read: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        try await store.requestAuthorization(toShare: [], read: read)
    }

    /// Quick, user-visible status for Heart Rate authorization.
    /// Used by Diagnostics to explain empty charts.
    static func heartRateStatusString() -> String {
        guard HKHealthStore.isHealthDataAvailable(),
              let type = HKObjectType.quantityType(forIdentifier: .heartRate)
        else { return "Unavailable" }

        switch store.authorizationStatus(for: type) {
        case .notDetermined:     return "Not Determined"
        case .sharingDenied:     return "Denied"
        case .sharingAuthorized: return "Authorized"
        @unknown default:        return "Unknown"
        }
    }

    /// Convenience boolean if you need branching logic.
    static func isAuthorizedForHeartRate() -> Bool {
        guard HKHealthStore.isHealthDataAvailable(),
              let type = HKObjectType.quantityType(forIdentifier: .heartRate)
        else { return false }
        return store.authorizationStatus(for: type) == .sharingAuthorized
    }

    // MARK: - Queries

    /// Fetch heart-rate samples for last `minutes` minutes (ascending by time).
    static func fetchRecentHeartRate(minutes: Int = 60) async throws -> [(Date, Double)] {
        guard let hrType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return [] }

        let end = Date()
        let start = end.addingTimeInterval(TimeInterval(-minutes * 60))
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let unit = HKUnit(from: "count/min")

        return try await withCheckedThrowingContinuation { cont in
            let query = HKSampleQuery(sampleType: hrType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: [sort]) { _, samples, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }
                let points: [(Date, Double)] = (samples as? [HKQuantitySample] ?? []).map {
                    ($0.startDate, $0.quantity.doubleValue(for: unit))
                }
                cont.resume(returning: points)
            }
            store.execute(query)
        }
    }

    /// Latest heart-rate sample if present.
    static func latestHeartRate() async throws -> (Date, Double)? {
        guard let hrType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return nil }
        let unit = HKUnit(from: "count/min")

        return try await withCheckedThrowingContinuation { cont in
            let q = HKSampleQuery(sampleType: hrType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, error in
                if let error { cont.resume(throwing: error); return }
                guard let s = (samples as? [HKQuantitySample])?.first else {
                    cont.resume(returning: nil); return
                }
                cont.resume(returning: (s.startDate, s.quantity.doubleValue(for: unit)))
            }
            store.execute(q)
        }
    }
}
