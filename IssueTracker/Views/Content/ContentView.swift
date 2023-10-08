//
//  ContentView.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        VStack {
            List(selection: $dataManager.selectedIssue) {
                ForEach(dataManager.issuesForSelectedFilter()) { issue in
                    IssueRow(issue: issue)
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("Issues")
        // Fix Tags in Filtering
        // This is not working in iOS17 due to a Apple "fix" that will not show tokens 
        // when the search field is not empty.
        .searchable(text: $dataManager.filterText,
                    tokens: $dataManager.filterTokens,
                    suggestedTokens: .constant(dataManager.suggestedFilterTokens),
                    prompt: "Filter issues, or type # to add tags"
        ) { tag in
            Text(tag.name)
        }
        .toolbar(content: ContentViewToolbar.init)
    }

    func delete(_ offsets: IndexSet) {
        let issues = dataManager.issuesForSelectedFilter()

        for offset in offsets {
            let item = issues[offset]
            dataManager.delete(item)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager(inMemory: true))
}
