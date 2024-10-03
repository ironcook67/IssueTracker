//
//  IssueRowViewModel.swift
//  IssueTracker
//
//  Created by Chon Torres on 9/26/24.
//

import Foundation

extension IssueRow {
    @dynamicMemberLookup
    class ViewModel: ObservableObject {
        let issue: Issue

        var iconOpacity: Double {
            issue.priority == 2 ? 1 : 0
        }

        var iconIdentifier: String {
            issue.priority == 2 ? "\(issue.title) High Priority": ""
        }

        var accessibilityHint: String {
            issue.priority == 2 ? "High Priority" : ""
        }

        var creationDate: String {
            issue.creationDate.formatted(date: .numeric, time: .omitted)
        }

        var accessibilityCreationDate: String {
            issue.creationDate.formatted(date: .abbreviated, time: .omitted)
        }

        init(issue: Issue) {
            self.issue = issue
        }

        subscript<Value>(dynamicMember keyPath: KeyPath<Issue, Value>) -> Value {
            issue[keyPath: keyPath]
        }
    }
}
