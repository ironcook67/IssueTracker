//
//  IssueRowWatch.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/24.
//

import SwiftUI

struct IssueRowWatch: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var issue: Issue

    var body: some View {
        NavigationLink(value: issue) {
            VStack(alignment: .leading) {
                Text(issue.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(issue.creationDate.formatted(date: .numeric, time: .omitted))
                    .font(.subheadline)
            }
            .foregroundStyle(issue.completed ? .secondary : .primary)
        }
    }
}

#Preview {
    IssueRowWatch(issue: .example)
        .environmentObject(DataManager.preview)
}
