//
//  DetailView.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack {
            if let issue = dataManager.selectedIssue {
                IssueView(issue: issue)
            } else {
                NoIssueView()
            }
        }
        .navigationTitle("Details")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

#Preview {
    DetailView()
        .environmentObject(DataManager(inMemory: true))
}
