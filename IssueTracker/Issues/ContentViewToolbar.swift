//
//  ContentViewToolbar.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/7/23.
//

import SwiftUI

struct ContentViewToolbar: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
#if !os(watchOS)
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
                .pickerStyle(.inline)
                .labelsHidden()

                Divider()

                Picker("Sort Order", selection: $dataManager.sortOldestFirst) {
                    Text("Newest to Oldest").tag(false)
                    Text("Oldest to Newest").tag(true)
                }
                .pickerStyle(.inline)
                .labelsHidden()
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
        .help("Filter")
#endif // !os(watchOS)

        Button(action: dataManager.newIssue) {
            Label("New Issue", systemImage: "square.and.pencil")
        }
        .help("New Issue")
    }
}

#Preview {
    ContentViewToolbar()
        .environmentObject(DataManager(inMemory: true))
}
