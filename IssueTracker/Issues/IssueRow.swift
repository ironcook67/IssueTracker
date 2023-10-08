//
//  IssueRow.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import SwiftUI

struct IssueRow: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var issue: Issue

    var body: some View {
        NavigationLink(value: issue) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(issue.priority == 2 ? 1 : 0)
                    .accessibilityIdentifier(issue.priority == 2 ? "\(issue.title) High Priority": "")

                VStack(alignment: .leading) {
                    Text(issue.title)
                        .font(.headline)
                        .lineLimit(1)

                    Text(issue.tagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(issue.formattedCreationDate)
                        .accessibilityLabel(issue.creationDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)

                    if issue.completed {
                        Text("CLOSED")
                            .font(.body.smallCaps())
                    }
                }
            }
            .foregroundStyle(.secondary)
        }
        .accessibilityHint(issue.priority == 2 ? "High Priority" : "")
        .accessibilityIdentifier(issue.title)
    }
}

#Preview {
    IssueRow(issue: .example)
        .environmentObject(DataManager(inMemory: true))
}
