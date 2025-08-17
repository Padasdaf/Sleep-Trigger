//
//  CloudHealthRow.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-15.
//

import SwiftUI

struct CloudHealthRow: View {
    let ok: Bool
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: ok ? "icloud.fill" : "exclamationmark.icloud.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(ok ? .green : .orange)
            Text(message)
                .foregroundStyle(ok ? .primary : .secondary)
        }
        .padding(.vertical, 4)
    }
}
