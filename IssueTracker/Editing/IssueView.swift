//
//  IssueView.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import SwiftUI

struct IssueView: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var issue: Issue

    @State private var showingNotificationError = false
    @Environment(\.openURL) var openURL

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $issue.title, prompt: Text("Enter the issue title here"))
                        .font(.title)
                        .labelsHidden()

                    Text("**Modified:** \(issue.modificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)

                    Text("**Status:** \(issue.status)")
                        .foregroundStyle(.secondary)
                }

                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag((Int16(0)))
                    Text("Medium").tag((Int16(1)))
                    Text("High").tag((Int16(2)))
                }

                TagsMenuView(issue: issue)
            }

            Section {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    TextField("Description", text: $issue.content,
                              prompt: Text("Enter the issue description here"),
                              axis: .vertical)
                }
                .labelsHidden()
            }

            Section("Reminders") {
                Toggle("Show reminders", isOn: $issue.reminderEnabled.animation())

                if issue.reminderEnabled {
                    DatePicker(
                        "Reminder time",
                        selection: $issue.reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
        }
        .formStyle(.grouped)
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            dataManager.queueSave()
        }
        .onSubmit(dataManager.save)
        .toolbar {
            IssueViewToolbar(issue: issue)
        }
        .alert("Opps!", isPresented: $showingNotificationError) {
#if os(macOS)
            SettingsLink {
                Text("Check Settings")
            }
#elseif os(iOS)
            Button("Check Settings", action: showAppSettings)
#endif // os(macOS)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("There was a problem setting your notification. Please check you have notifications enabled.")
        }
        .onChange(of: issue.reminderEnabled) { _, _ in
            updateReminder()
        }
        .onChange(of: issue.reminderTime) { _, _ in
            updateReminder()
        }
    }

#if os(iOS)
    func showAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else {
            return
        }

        openURL(settingsURL)
    }
#endif // is(iOS)

    func updateReminder() {
        dataManager.removeReminder(for: issue)

        Task { @MainActor in
            if issue.reminderEnabled {
                let success = await dataManager.addReminder(for: issue)

                if success == false {
                    issue.reminderEnabled = false
                    showingNotificationError = true
                }
            }
        }
    }
}

#Preview {
    IssueView(issue: .example)
        .environmentObject(DataManager(inMemory: true))
}
