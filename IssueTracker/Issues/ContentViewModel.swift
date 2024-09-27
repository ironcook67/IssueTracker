//
//  ContentViewModel.swift
//  IssueTracker
//
//  Created by Chon Torres on 9/26/24.
//

import Foundation

extension ContentView {
    class ViewModel: ObservableObject {
        var dataManager: DataManager

        init(dataManager: DataManager) {
            self.dataManager = dataManager
        }

        func delete(_ offsets: IndexSet) {
            let issues = dataManager.issuesForSelectedFilter()

            for offset in offsets {
                let item = issues[offset]
                dataManager.delete(item)
            }
        }
    }
}
