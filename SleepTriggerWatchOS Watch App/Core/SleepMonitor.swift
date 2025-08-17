//
//  SleepMonitor.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation
import HealthKit
import Combine

@MainActor
final class SleepMonitor: ObservableObject {
    private let store = HKHealthStore()
    private let heart: HeartRateStream
    private let motion = DeviceMotionMonitor()

    // Trend + state machine
    private let hrTrend = HRTrendAnalyzer()
    private let fsm     = SleepStateMachine()

    // Lightweight filters
    private let hrLPF    = IIR1(alpha: 0.22)
    private let stillLPF = IIR1(alpha: 0.12)

    // Robust stats (HR)
    private var hrHampel = rs_hampel_t()
    private var hrVar    = rs_var_t()

    // Windows + spectral (stillness)
    private let hrWindow    = RingBufferF32(capacity: 60)
    private let stillWindow = RingBufferF32(capacity: 64)
    private var goertzel    = goertzel_t()

    // Fusion + smoothing (your wrappers)
    private let ekf = EKFWrapper(q: 0.01, r: 0.10, x0: 0, p0: 1)
    private let hmm = HMMWrapper()

    // Duty control (C)
    private var duty = duty_ctrl_t()

    private var cancellables = Set<AnyCancellable>()

    // Guards
    private var hrSampleCount = 0
    private let minHRSamplesToDecide = 8
    private var asleepStableTicks = 0
    private let asleepConfirmTicks = 2

    // UI/debug
    @Published private(set) var isRunning = false
    @Published private(set) var currentBPM: Double?
    @Published private(set) var stillnessScore: Double = 0
    @Published private(set) var propensity: Double = 0
    @Published private(set) var state: SleepState = .awake

    // Ring logger must be var (append is mutating)
    private var logger = RingLogger(capacity: 600)
    var ringLogger: RingLogger { logger }

    init() {
        self.heart = HeartRateStream(store: store)

        // robust stats init
        rs_hampel_init(&hrHampel, 9, 3.0)   // 9-sample window, 3σ
        rs_var_init(&hrVar)

        // spectral around ~0.2 Hz on ~1 Hz stillness samples
        goertzel_init(&goertzel, 1.0, 0.20, 32)

        // duty control defaults (2s drowsy, 5s otherwise)
        dc_init(&duty, 2.0, 5.0)

        // Heart stream
        heart.$latestBPM
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] raw in
                guard let self else { return }

                let cleaned  = rs_hampel_update(&hrHampel, raw)
                rs_var_update(&hrVar, cleaned)
                let smoothed = Double(self.hrLPF.update(Float(cleaned)))

                self.currentBPM = smoothed
                self.hrTrend.ingest(smoothed)
                self.hrWindow.push(Float(smoothed))

                self.hrSampleCount += 1
                self.evaluate()
            }
            .store(in: &cancellables)

        // Stillness stream
        motion.$stillnessScore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] raw in
                guard let self else { return }
                let s = Double(self.stillLPF.update(Float(raw)))
                self.stillnessScore = s
                self.stillWindow.push(Float(s))
                goertzel_push(&goertzel, s)
                self.evaluate()
            }
            .store(in: &cancellables)
    }

    func start() {
        Task { @MainActor in
            do {
                try await WatchHealthAuthorization.shared.request()
                try heart.start()
                motion.start()
                fsm.reset()
                hrSampleCount = 0
                asleepStableTicks = 0
                isRunning = true
            } catch {
                print("Start error: \(error)")
            }
        }
    }

    func stop() {
        heart.stop()
        motion.stop()
        fsm.reset()
        isRunning = false
        asleepStableTicks = 0
        hrWindow.clear()
        stillWindow.clear()
        goertzel_reset(&goertzel)
    }

    // Helper that works whether inputs are Double or Double?
    @inline(__always) private func val(_ x: Double) -> Double { x }
    @inline(__always) private func val(_ x: Double?) -> Double { x ?? 0 }

    // MARK: - Decision core
    private func evaluate() {
        guard hrSampleCount >= minHRSamplesToDecide else { return }

        // HR trend (optionals safe)
        let drop  = val(hrTrend.dropFraction)      // 0…1, 0 if not ready yet
        let slope = val(hrTrend.slopeBPMPerSec)    // neg when dozing
        let negSlope = max(0.0, min(1.0, -slope / 0.2))

        // Stillness features (use smoothed score; no API calls on buffer)
        let stillMean = stillnessScore
        let stillVar  = 0.0

        // VLF power once we have enough samples
        var vlf: Double = 0
        if stillWindow.count >= 32 {
            vlf = goertzel_power(&goertzel)
            vlf = min(1.0, vlf / 5.0)
        }

        // Tiny motion class & respiration proxy
        let motionClass = tiny_motion_classify(stillMean, stillVar) // 0 quiet / 1 small / 2 move
        let respQuiet   = (motionClass == 0) ? 1.0 : (motionClass == 1 ? 0.6 : 0.2)

        // EKF fusion → propensity (0…1)
        let p = ekf.update(withDrop: drop,
                           still: stillMean,
                           negSlope: negSlope,
                           respQuiet: respQuiet,
                           vlfPower: vlf)
        propensity = p

        // FSM → observation, then HMM smoothing
        var newState = fsm.ingest(dropFraction: drop, stillness: stillMean, slope: slope)
        let obs: Int = {
            if case .awake  = newState { return 0 }
            if case .drowsy = newState { return 1 }
            return 2
        }()
        let sm = hmm.step(withObservation: obs)
        newState = (sm == 0 ? .awake : (sm == 1 ? .drowsy(since: Date()) : .asleep(at: Date())))

        // Assist with propensity
        if p > 0.85, case .drowsy = newState { newState = .asleep(at: Date()) }
        if p < 0.25, case .drowsy = newState { newState = .awake }

        // Apply
        state = newState

        // Log one row per tick (hr is Optional by design)
        let stateRaw: Int = {
            if case .awake  = state { return 0 }
            if case .drowsy = state { return 1 }
            return 2
        }()
        logger.append(
            hr: currentBPM,
            still: stillMean,
            drop: drop,
            slope: slope,
            propensity: p,
            stateRaw: stateRaw
        )

        // Confirmed-asleep handling
        if case .asleep = state {
            asleepStableTicks += 1
            if asleepStableTicks >= asleepConfirmTicks {
                WatchConnectivityManager.shared.sendSleepOnset()
                stop()
            }
        } else {
            asleepStableTicks = 0
        }

        // Duty pacing: supply a dc_state_t
        let dcState: dc_state_t = {
            if case .drowsy = state { return DC_DROWSY }
            if case .asleep = state { return DC_ASLEEP }
            return DC_AWAKE
        }()
        _ = dc_next_interval(&duty, dcState)
    }
}
