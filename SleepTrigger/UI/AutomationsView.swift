//
//  AutomationsView.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import SwiftUI

struct AutomationsView: View {
    @ObservedObject var store = AutomationsStore.shared
    @State private var newName: String = ""

    var body: some View {
        VStack {
            List {
                Section {
                    HStack {
                        TextField("Shortcut name (as in Shortcuts app)", text: $newName)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        Button("Add") {
                            store.add(newName)
                            newName = ""
                        }.disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section(header: Text("On detection")) {
                    ForEach(store.items) { item in
                        AutomationRow(item: item)
                    }
                    .onDelete(perform: store.remove)
                    .onMove(perform: store.move)
                }
            }
            .environment(\.editMode, .constant(.active)) // allow reordering by default
        }
        .navigationTitle("Automations")
    }
}

struct AutomationRow: View {
    @ObservedObject var store = AutomationsStore.shared
    let item: AutomationItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.name).bold()
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { item.enabled },
                        set: { enabled in
                            if let idx = store.items.firstIndex(of: item) {
                                store.items[idx].enabled = enabled
                            }
                        })
                    )
                    .labelsHidden()
                }
                HStack(spacing: 8) {
                    Text("Delay")
                    Stepper("\(item.delaySeconds)s", value: Binding(
                        get: { item.delaySeconds },
                        set: { val in
                            if let idx = store.items.firstIndex(of: item) {
                                store.items[idx].delaySeconds = max(0, min(300, val))
                            }
                        }), in: 0...300)
                    .labelsHidden()
                    Spacer()
                    Button {
                        store.setMaster(item)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: item.isMaster ? "star.fill" : "star")
                            Text("Master")
                        }.foregroundStyle(item.isMaster ? Color.yellow : .secondary)
                    }
                    .buttonStyle(.plain)
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
    }
}
