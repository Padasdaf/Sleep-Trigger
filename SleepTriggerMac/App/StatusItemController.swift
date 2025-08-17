//
//  StatusItemController.swift
//  SleepTriggerMac
//
//  Created by Daniel Hu on 2025-08-14.
//

import AppKit

/// Menu bar controller for the macOS companion.
/// Shows listening state, last mirrored onset, and a few handy actions.
@MainActor
final class StatusItemController {

    // MARK: - UI
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let titleItem = NSMenuItem(title: "SleepTrigger Mac — Listening", action: nil, keyEquivalent: "")
    private let lastOnsetItem = NSMenuItem(title: "Last Onset: —", action: nil, keyEquivalent: "")
    private lazy var toggleListenItem = NSMenuItem(
        title: "Stop Listening",
        action: #selector(toggleListening),
        keyEquivalent: "l"
    )

    // MARK: - Dependencies / State
    private lazy var listener: CloudListener = {
        CloudListener(onOnset: { [weak self] date, _ in
            guard let self, self.isListening else { return }
            self.lastOnsetItem.title = "Last Onset: " + self.df.string(from: date)

            // Optional behaviors driven by Preferences
            let prefs = MacSettings.shared
            if prefs.enableNotifications {
                MacNotificationManager.shared.notifyOnset(date: date)
            }
            if prefs.alsoPauseMedia {
                ScriptRunner.shared.pauseMedia()
            }
            if !prefs.shortcutName.isEmpty {
                self.runShortcut(named: prefs.shortcutName)
            }
        })
    }()

    private var isListening = true
    private var pollTimer: Timer?

    private lazy var df: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .medium
        return f
    }()

    // MARK: - Lifecycle
    init() {
        buildMenu()
        startPollingLastOnset()   // display refresh
        listener.start()          // begin listening
        MacNotificationManager.shared.requestPermissionIfNeeded()
    }

    deinit { pollTimer?.invalidate() }

    // MARK: - Menu
    private func buildMenu() {
        item.button?.title = "🌙"

        let menu = NSMenu()
        titleItem.isEnabled = false
        lastOnsetItem.isEnabled = false

        menu.addItem(titleItem)
        menu.addItem(lastOnsetItem)
        menu.addItem(.separator())

        // Listening toggle
        toggleListenItem.target = self
        menu.addItem(toggleListenItem)

        // Preferences
        let prefs = NSMenuItem(title: "Preferences…", action: #selector(openPreferences), keyEquivalent: ",")
        prefs.target = self
        menu.addItem(prefs)

        // Test actions (debug only)
        #if DEBUG
        let pause = NSMenuItem(title: "Pause Media (test)", action: #selector(testPause), keyEquivalent: "p")
        pause.target = self
        menu.addItem(pause)

        let focus = NSMenuItem(title: "Enable Focus (test)", action: #selector(testFocus), keyEquivalent: "f")
        focus.target = self
        menu.addItem(focus)
        #endif

        // Run an arbitrary Shortcut by name
        let runShort = NSMenuItem(title: "Run Shortcut…", action: #selector(runShortcutPrompt), keyEquivalent: "r")
        runShort.target = self
        menu.addItem(runShort)

        menu.addItem(.separator())

        let about = NSMenuItem(title: "About SleepTrigger Mac", action: #selector(showAbout), keyEquivalent: "")
        about.target = self
        menu.addItem(about)

        let quit = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        item.menu = menu
    }

    // MARK: - Polling (display only)
    private func startPollingLastOnset() {
        refreshLastOnsetLabel()

        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refreshLastOnsetLabel() }
        }
        pollTimer?.tolerance = 5
        if let pollTimer { RunLoop.main.add(pollTimer, forMode: .common) }
    }

    private func refreshLastOnsetLabel() {
        let kv = NSUbiquitousKeyValueStore.default
        _ = kv.synchronize()
        if let t = kv.object(forKey: "lastOnset") as? Double {
            let d = Date(timeIntervalSince1970: t)
            lastOnsetItem.title = "Last Onset: " + df.string(from: d)
        } else {
            lastOnsetItem.title = "Last Onset: —"
        }
    }

    // MARK: - Actions
    @objc private func toggleListening() {
        if isListening {
            listener.stop()
            titleItem.title = "SleepTrigger Mac — Paused"
            toggleListenItem.title = "Start Listening"
            item.button?.title = "⏸️"
        } else {
            listener.start()
            titleItem.title = "SleepTrigger Mac — Listening"
            toggleListenItem.title = "Stop Listening"
            item.button?.title = "🌙"
        }
        isListening.toggle()
    }

    @objc private func openPreferences() {
        MacPreferencesWindow.shared.show()
    }

    #if DEBUG
    @objc private func testPause() { ScriptRunner.shared.pauseMedia() }
    @objc private func testFocus() { ScriptRunner.shared.enableFocus() }
    #endif

    @objc private func runShortcutPrompt() {
        let alert = NSAlert()
        alert.messageText = "Run Shortcut"
        alert.informativeText = "Enter the name of a Shortcut to run."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Run")
        alert.addButton(withTitle: "Cancel")

        let tf = NSTextField(string: "")
        tf.placeholderString = "Shortcut name"
        tf.frame = NSRect(x: 0, y: 0, width: 260, height: 24)
        alert.accessoryView = tf

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }

        let name = tf.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        runShortcut(named: name)
    }

    private func runShortcut(named: String) {
        let encoded = named.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? named
        if let url = URL(string: "shortcuts://run-shortcut?name=\(encoded)") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func showAbout() {
        NSApp.orderFrontStandardAboutPanel(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quit() {
        pollTimer?.invalidate()
        NSApp.terminate(nil)
    }
}
