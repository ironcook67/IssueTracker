//
//  TagsMenuView.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/7/23.
//

import SwiftUI

struct TagsMenuView: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var issue: Issue

    var body: some View {
#if !os(watchOS)
        Menu {
            ForEach(issue.sortedTags) { tag in
                Button {
                    issue.removeFromTags(tag)
                } label: {
                    Label(tag.name, systemImage: "checkmark")
                }
            }

            // now show other tags
            let otherTags = dataManager.missingTags(from: issue)

            if otherTags.isEmpty == false {
                Divider()

                Section("Add Tags") {
                    ForEach(otherTags) { tag in
                        Button(tag.name) {
                            issue.addToTags(tag)
                        }
                    }
                }
            }
        } label: {
            Text(issue.tagsList)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(nil, value: issue.tagsList)
        }
#endif // !os(watchOS)
    }
}

#Preview {
    TagsMenuView(issue: .example)
        .environmentObject(DataManager(inMemory: true))
}
