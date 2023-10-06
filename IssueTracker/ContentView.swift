//
//  ContentView.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var issues: [Issue] {
        let filter = dataManager.selectedFilter ?? .all
        var allIssues: [Issue]
        
        if let tag = filter.tag {
            allIssues = Array(tag.issues)
        } else {
            let request = Issue.fetchRequest()
            request.predicate = NSPredicate(format: "modificationDate_ > %@", filter.minModificationDate as NSDate)
            allIssues = (try? dataManager.container.viewContext.fetch(request)) ?? []
        }
        
        return allIssues.sorted()
    }
    
    var body: some View {
        VStack {
            List(selection: $dataManager.selectedIssue) {
                ForEach(issues) { issue in
                    IssueRow(issue: issue)
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("Issues")
    }
    
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = issues[offset]
            dataManager.delete(item)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager.preview)
}
