//
//  GlassCard.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ content: () -> Content) { self.content = content() }
    var body: some View { content.glassCard() }
}
