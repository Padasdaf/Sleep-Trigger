//
//  SleepTriggerTests.swift
//  SleepTriggerTests
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation
import Testing
@testable import SleepTrigger

struct SleepTriggerTests {

    /// Export should always create a CSV with a header. After we seed one onset,
    /// the file should contain at least two lines (header + one row).
    @Test
    func exportHistoryCSV_hasHeaderAndAtLeastOneRow() async throws {
        // Seed one onset for "today"
        HistoryDAO.recordOnset(Date())

        // Export last day
        let url = await ExportManager.exportHistoryCSV(days: 1)
        #expect(url != nil)

        guard let u = url else { return }

        // Read and validate contents
        let text = try String(contentsOf: u, encoding: .utf8)
        let lines = text.split(whereSeparator: \.isNewline)
        #expect(lines.count >= 2)
        #expect(lines.first == "date,count")

        // Clean up temp file
        try? FileManager.default.removeItem(at: u)
    }

    /// Sanity-check the spectral helper: a sine at `freqTarget` should yield
    /// substantially more Goertzel power at that frequency than at an off-target.
    @Test
    func goertzelDetectsTargetFrequency() {
        // Build two frames of a small sine wave at 2 Hz sampled at 200 Hz
        let sr: Float = 200
        let freqTarget: Float = 2
        let n = 200

        let frame: [Float] = (0..<n).map { i in
            let t = Float(i) / sr
            return sin(2 * .pi * freqTarget * t) * 0.9  // modest amplitude
        }
        let frames = [frame, frame]

        let pTarget = MetalSpectral.goertzelPowers(
            frames: frames, freq: freqTarget, sampleRate: sr
        ).reduce(0, +) / Float(frames.count)

        let pOff = MetalSpectral.goertzelPowers(
            frames: frames, freq: 5, sampleRate: sr
        ).reduce(0, +) / Float(frames.count)

        // Target power should clearly dominate.
        #expect(pTarget > pOff * 3, "Expected target power \(pTarget) > 3× off-target \(pOff)")
    }
}
