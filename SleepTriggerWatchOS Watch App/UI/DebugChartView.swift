//
//  DebugChartView.swift
//  SleepTriggerWatchOS Watch App
//
//  Created by Daniel Hu on 2025-08-14.
//

import SwiftUI

struct DebugChartView: View {
    let values: [Double]
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let minV = values.min() ?? 0, maxV = values.max() ?? 1
            let span = max(maxV - minV, 1)

            Path { p in
                for (i, v) in values.enumerated() {
                    let x = w * CGFloat(i) / CGFloat(max(values.count - 1, 1))
                    let y = h - CGFloat((v - minV) / span) * h
                    i == 0 ? p.move(to: .init(x: x, y: y)) : p.addLine(to: .init(x: x, y: y))
                }
            }
            .stroke(lineWidth: 1.5)
        }
        .frame(height: 60)
    }
}
