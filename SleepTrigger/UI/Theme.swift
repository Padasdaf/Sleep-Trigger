//
//  Theme.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import SwiftUI

enum Theme {
    static let bg = LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)

    struct Card: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
        }
    }
}
extension View { func glassCard() -> some View { modifier(Theme.Card()) } }
