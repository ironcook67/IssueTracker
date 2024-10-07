//
//  IssueViewToolbar.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/7/23.
//

#if canImport(CoreHaptics)
import CoreHaptics
#endif // canImport(CoreHaptics)
import SwiftUI

struct IssueViewToolbar: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var issue: Issue

#if canImport(CoreHaptics)
    @State private var engine = try? CHHapticEngine()
#endif // canImport(CoreHaptics)

    var openCloseButtonText: LocalizedStringKey {
        issue.completed ? "Re-open Issue" : "Close Issue"
    }

    var body: some View {
#if !os(watchOS)
        Menu {
            Button("Copy Issue Title", systemImage: "doc.on.doc", action: copyToClipboard)
             
            Button(action: toggleCompleted) {
                Label(openCloseButtonText,
                      systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }
#if canImport(CoreHaptics)
            // Comment in for default haptics.
//            .sensoryFeedback(trigger: issue.completed) { _, newValue in
//                if newValue {
//                    .success
//                } else {
//                    nil
//                }
//            }
#endif // canImport(CoreHaptics)
            
            Divider()

            Section("Tags") {
                TagsMenuView(issue: issue)
            }
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
#endif // !os(watchOS)

    }

    func toggleCompleted() {
        issue.completed.toggle()
        dataManager.save()

#if canImport(CoreHaptics)
        // Comment in for custom haptics.
        if issue.completed {
            do {
                try engine?.start()

                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)

                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)

                let paramCurve = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0
                )

                let event1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: 0
                )

                let event2 = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [sharpness, intensity],
                    relativeTime: 0.125,
                    duration: 1
                )

                let pattern = try CHHapticPattern(
                    events: [event1, event2],
                    parameterCurves: [paramCurve]
                )

                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                // playing haptics did not work and that is OK.
            }
        }
#endif // canImport(CoreHaptics)
    }

    func copyToClipboard() {
#if os(iOS)
        UIPasteboard.general.string = issue.title
#elseif os(macOS)
        NSPasteboard.general.prepareForNewContents()
        NSPasteboard.general.setString(issue.title, forType: .string)
#endif // os(iOS)
    }
}

#Preview {
    IssueViewToolbar(issue: .example)
        .environmentObject(DataManager(inMemory: true))
}
