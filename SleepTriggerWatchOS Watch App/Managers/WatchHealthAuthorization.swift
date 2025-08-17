//
//  WatchHealthAuthorization.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation
import HealthKit

final class WatchHealthAuthorization {
    static let shared = WatchHealthAuthorization()
    let store = HKHealthStore()

    func request() async throws {
        let types: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        try await store.requestAuthorization(toShare: [], read: types)
    }
}
