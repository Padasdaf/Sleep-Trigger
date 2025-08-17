//
//  MacPreferencesWindow.swift
//  SleepTriggerMac
//
//  Created by Daniel Hu on 2025-08-16.
//

import SwiftUI
import AppKit

// MARK: - View

@MainActor
struct MacPreferencesView: View {
    @ObservedObject private var settings = MacSettings.shared

    var body: some View {
        Form {
            // Notifications ---------------------------------------------------
            Section("Notifications") {
                Toggle(
                    "Show notification when sleep is mirrored",
                    isOn: $settings.enableNotifications
                )
            }

            // Automation ------------------------------------------------------
            Section("Automation") {
                Toggle(
                    "Also pause media on mirror",
                    isOn: $settings.alsoPauseMedia
                )

                HStack {
                    Text("Shortcut to run:")
                    TextField("Optional Shortcut name", text: $settings.shortcutName)
                        .textFieldStyle(.roundedBorder)
                }

                Text("Leave blank to skip running a Shortcut.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(width: 420)
        // SwiftUI macOS 14+ onChange API: use the overload with `initial:` and
        // a zero-parameter closure (or a two-parameter old/new closure).
        .onChange(of: settings.enableNotifications, initial: false) {
            settings.save()
        }
        .onChange(of: settings.alsoPauseMedia, initial: false) {
            settings.save()
        }
        .onChange(of: settings.shortcutName, initial: false) {
            settings.save()
        }
    }
}

// MARK: - Optional window presenter

@MainActor
final class MacPreferencesWindow {
    static let shared = MacPreferencesWindow()

    private var window: NSWindow?

    func show() {
        if window == nil {
            let hosting = NSHostingView(rootView: MacPreferencesView())
            let w = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 360),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            w.title = "SleepTrigger Preferences"
            w.center()
            w.contentView = hosting
            window = w
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
