//
//  DataManager+Notifications.swift
//  IssueTracker
//
//  Created by Chon Torres on 9/26/24.
//

import Foundation
import UserNotifications

extension DataManager {
    func addReminder(for issue: Issue) async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()

            switch settings.authorizationStatus {
            case .notDetermined:
                let success = try await requestNotifications()

                if success {
                    try await placeReminders(for: issue)
                } else {
                    return false
                }
            case .authorized:
                try await placeReminders(for: issue)

            default:
                return false
            }

            return true
        } catch {
            print("Error adding reminder \(issue.title): \(error.localizedDescription)")
            return false
        }
    }

    func removeReminder(for issue: Issue) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [issue.identifier])
    }

    private func requestNotifications() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        return try await center.requestAuthorization(options: [.alert, .sound])
    }

    private func placeReminders(for issue: Issue) async throws {
        let content = UNMutableNotificationContent()
        content.title = issue.title
        content.sound = .default
        content.subtitle = issue.content

        // Remove comments for final version
        let components = Calendar.current.dateComponents([.hour, .minute], from: issue.reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        // The code below is for testing only.
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: issue.identifier, content: content, trigger: trigger)

        return try await UNUserNotificationCenter.current().add(request)
    }
}
