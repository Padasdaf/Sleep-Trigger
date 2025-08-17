//
//  ContentView.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Home tab
            NavigationStack { HomeView() }
                .tabItem { Label("Home", systemImage: "house") }

            // Automations tab
            NavigationStack { AutomationsView() }
                .tabItem { Label("Automations", systemImage: "bolt.fill") }

            // History tab
            NavigationStack { HistoryView() }
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }

            // Diagnostics tab
            NavigationStack { DiagnosticsView() }
                .tabItem { Label("Diagnostics", systemImage: "waveform.path.ecg") }

            // Developer tab (hidden in Release). Toggle via FeatureFlags.developerMode.
            #if DEBUG
            if FeatureFlags.developerMode {
                DeveloperPanelView()
                    .tabItem { Label("Dev", systemImage: "hammer") }
            }
            #endif
        }
    }
}

#Preview {
    ContentView()
}
