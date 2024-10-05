//
//  ContentView.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import SwiftUI

struct ContentView: View {
#if !os(watchOS)
    @Environment(\.requestReview) var requestReview
#endif // !os(watchOS)

    @StateObject var viewModel: ViewModel

    private let newIssueActivity = "com.chontorres.issuetracker.newIssue"

    init(dataManager: DataManager) {
        let viewModel = ViewModel(dataManager: dataManager)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(selection: $viewModel.selectedIssue) {
            ForEach(viewModel.dataManager.issuesForSelectedFilter()) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: viewModel.delete)
        }
        .macFrame(minWidth: 220)
        .navigationTitle("Issues")
#if !os(watchOS)
        // Fix Tags in Filtering
        // This is not working in iOS17 due to a Apple "fix" that will not show tokens 
        // when the search field is not empty.
        .searchable(text: $viewModel.filterText,
                    tokens: $viewModel.filterTokens,
                    suggestedTokens: .constant(viewModel.suggestedFilterTokens),
                    prompt: "Filter issues, or type # to add tags"
        ) { tag in
            Text(tag.name)
        }
#endif // !os(watchOS)
        .toolbar(content: ContentViewToolbar.init)
        .onAppear(perform: askForReview)
        .onOpenURL(perform: viewModel.openURL)
        .userActivity(newIssueActivity) { activity in
#if !os(macOS)
            activity.isEligibleForPrediction = true
#endif
            activity.title = "New Issue"
        }
        .onContinueUserActivity(newIssueActivity, perform: resumeActivity)
    }

    func askForReview() {
#if !os(watchOS)
        if viewModel.shouldRequestReview {
            requestReview()
        }
#endif // !os(watchOS)
    }

    func resumeActivity(_ userActivity: NSUserActivity) {
        viewModel.dataManager.newIssue()
    }
}

#Preview {
    ContentView(dataManager: .preview)
}
