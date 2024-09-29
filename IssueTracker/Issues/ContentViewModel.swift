//
//  ContentViewModel.swift
//  IssueTracker
//
//  Created by Chon Torres on 9/26/24.
//

import Foundation

extension ContentView {
    @dynamicMemberLookup
    class ViewModel: ObservableObject {
        var dataManager: DataManager

        var shouldRequestReview: Bool {
            dataManager.count(for: Tag.fetchRequest()) >= 5
        }

        init(dataManager: DataManager) {
            self.dataManager = dataManager
        }

        subscript<Value>(dynamicMember keyPath: KeyPath<DataManager, Value>) -> Value {
            dataManager[keyPath: keyPath]
        }

        subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<DataManager, Value>) -> Value {
            get { dataManager[keyPath: keyPath] }
            set { dataManager[keyPath: keyPath] = newValue }
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
