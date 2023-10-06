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
        // TODO: - Fix Tags in Filtering
        // This is not working in iOS17 due to a Apple "fix" that will not show tokens when the search field is not empty.
        .searchable(text: $dataManager.filterText, tokens: $dataManager.filterTokens, suggestedTokens: .constant(dataManager.suggestedFilterTokens), prompt: "Filter issues, or type # to add tags") { tag in
            Text(tag.name)
        }
        .toolbar {
            Menu {
                Button(dataManager.filterEnabled ? "Turn Filter Off" : "Turn Filter On") {
                    dataManager.filterEnabled.toggle()
                }
                
                Divider()
                
                Menu("Sort By") {
                    Picker("Sort By", selection: $dataManager.sortType) {
                        Text("Date Created").tag(SortType.dateCreated)
                        Text("Date Modified").tag(SortType.dateModified)
                    }
                    
                    Divider()
                    
                    Picker("Sort Order", selection: $dataManager.sortOldestFirst) {
                        Text("Newest to Oldest").tag(false)
                        Text("Oldest to Newest").tag(true)
                    }
                }
                
                Picker("Status", selection: $dataManager.filterStatus) {
                    Text("All").tag(Status.all)
                    Text("Open").tag(Status.open)
                    Text("Closed").tag(Status.closed)
                }
                .disabled(dataManager.filterEnabled == false)
                
                Picker("Priority", selection: $dataManager.filterPriority) {
                    Text("All").tag(-1)
                    Text("Low").tag(0)
                    Text("Medium").tag(1)
                    Text("High").tag(2)
                }
                .disabled(dataManager.filterEnabled == false)
                
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    .symbolVariant(dataManager.filterEnabled ? .fill : .none)
            }
            
            Button(action: dataManager.newIssue) {
                Label("New Issue", systemImage: "square.and.pencil")
            }
        }
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
        .environmentObject(DataManager.preview)
}
