//
//  IssueViewToolbar.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/7/23.
//

import CoreHaptics
import SwiftUI

struct IssueViewToolbar: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var issue: Issue

    @State private var engine = try? CHHapticEngine()

    var openCloseButtonText: LocalizedStringKey {
        issue.completed ? "Re-open Issue" : "Close Issue"
    }

    var body: some View {
        Menu {
            Button {
#if os(iOS)
                UIPasteboard.general.string = issue.title
#endif
            } label: {
                Label("Copy Issue Title", systemImage: "doc.on.doc")
            }

            Button(action: toggleCompleted) {
                Label(openCloseButtonText,
                      systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }
            // Comment in for default haptics.
//            .sensoryFeedback(trigger: issue.completed) { _, newValue in
//                if newValue {
//                    .success
//                } else {
//                    nil
//                }
//            }

            Divider()

            Section("Tags") {
                TagsMenuView(issue: issue)
            }
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
    }

    func toggleCompleted() {
        issue.completed.toggle()
        dataManager.save()

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
    }
}

#Preview {
    IssueViewToolbar(issue: .example)
        .environmentObject(DataManager(inMemory: true))
}
