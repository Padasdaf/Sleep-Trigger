//
//  OnboardingView.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0

    // Local form state for settings
    @State private var shortcutName = AppSettings.shared.shortcutName
    @State private var iCloudOn = AppSettings.shared.iCloudMirrorEnabled
    @State private var smartAlarmOn = AppSettings.shared.smartAlarmEnabled
    @State private var smartAlarmMin = AppSettings.shared.smartAlarmWindowMinutes
    @State private var retentionDays = AppSettings.shared.dataRetentionDays

    var body: some View {
        TabView(selection: $page) {
            OnboardPage(title: "Welcome to SleepTrigger",
                        text: "Run any Shortcut the moment you fall asleep. Works with your Apple Watch.",
                        systemImage: "moon.zzz.fill")
                .tag(0)

            ChecklistPage().tag(1)

            VStack(spacing: 18) {
                Text("Pick Your Master Shortcut").font(.title3.bold())
                Text("This is what we’ll run on sleep. You can change it later.")
                    .font(.subheadline).foregroundStyle(.secondary)

                HStack {
                    TextField("Master Shortcut Name", text: $shortcutName)
                        .textFieldStyle(.roundedBorder)
                    Button("Open Shortcuts") { openShortcuts() }
                        .buttonStyle(.bordered)
                }
                .padding(.horizontal)

                Toggle("Enable Smart Alarm", isOn: $smartAlarmOn)
                    .padding(.horizontal)
                if smartAlarmOn {
                    HStack {
                        Text("Alarm window (min)")
                        Spacer()
                        Stepper(value: $smartAlarmMin, in: 1...30) {
                            Text("\(smartAlarmMin)")
                        }
                    }
                    .padding(.horizontal)
                }

                Toggle("Mirror last onset to iCloud", isOn: $iCloudOn)
                    .padding(.horizontal)

                HStack {
                    Text("Retain history (days)")
                    Spacer()
                    Stepper(value: $retentionDays, in: 7...365) {
                        Text("\(retentionDays)")
                    }
                }
                .padding(.horizontal)

                Button {
                    // Persist selections
                    let s = AppSettings.shared
                    s.shortcutName = shortcutName
                    s.smartAlarmEnabled = smartAlarmOn
                    s.smartAlarmWindowMinutes = smartAlarmMin
                    s.iCloudMirrorEnabled = iCloudOn
                    s.dataRetentionDays = retentionDays
                    s.hasCompletedOnboarding = true
                    dismiss()
                } label: {
                    Label("Finish Setup", systemImage: "checkmark.circle.fill")
                        .font(.title3.bold())
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            .padding()
            .tag(2)
        }
        .tabViewStyle(.page)
    }

    private func openShortcuts() {
        if let url = URL(string: "shortcuts://") {
            UIApplication.shared.open(url)
        }
    }
}

private struct OnboardPage: View {
    let title: String
    let text: String
    let systemImage: String
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: systemImage).font(.system(size: 56))
            Text(title).font(.title.bold())
            Text(text).multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Spacer()
        }
        .padding()
    }
}

private struct ChecklistPage: View {
    @State private var notifGranted: Bool? = nil
    @State private var watchPairedHint = "Pair Watch + iPhone (Simulators menu)"
    @State private var healthHint = "Grant Health on Watch app when asked"

    var body: some View {
        VStack(spacing: 16) {
            Text("Before You Start").font(.title3.bold())

            ChecklistRow(checked: notifGranted == true,
                         title: "Allow Notifications",
                         subtitle: "We’ll alert you and can add actions.",
                         actionTitle: notifGranted == true ? "Granted" : "Request") {
                requestNotifications()
            }

            ChecklistRow(checked: false,
                         title: "Pair Your Watch",
                         subtitle: watchPairedHint,
                         actionTitle: "Open Simulators") {
                if let url = URL(string: "xcrun://simulators") {
                    UIApplication.shared.open(url) // FYI: this will no-op on device, fine on dev
                }
            }

            ChecklistRow(checked: false,
                         title: "Health Permission",
                         subtitle: healthHint,
                         actionTitle: "Learn More") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear { refreshNotificationsStatus() }
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { ok, _ in
            DispatchQueue.main.async { notifGranted = ok }
        }
    }
    private func refreshNotificationsStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { st in
            DispatchQueue.main.async { notifGranted = (st.authorizationStatus == .authorized) }
        }
    }
}

private struct ChecklistRow: View {
    let checked: Bool
    let title: String
    let subtitle: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(checked ? .green : .secondary)
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button(actionTitle, action: action)
                .buttonStyle(.bordered)
        }
        .padding(.vertical, 6)
    }
}
