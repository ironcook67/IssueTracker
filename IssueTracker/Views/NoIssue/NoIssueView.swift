//
//  NoIssueView.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import SwiftUI

struct NoIssueView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        Text("No Issue Selected")
            .font(.title)
            .foregroundStyle(.secondary)
        
        Button("New Issue") {
            dataManager.newIssue()
        }
    }
}

#Preview {
    NoIssueView()
        .environmentObject(DataManager(inMemory: true))
}
