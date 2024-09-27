//
//  Issue+Ext.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import Foundation

extension Issue {
    var identifier: String {
        get { objectID.uriRepresentation().absoluteString }
    }

    var title: String {
        get { title_ ?? "" }
        set { title_ = newValue }
    }

    var content: String {
        get { content_ ?? "" }
        set { content_ = newValue }
    }

    var creationDate: Date {
        get { creationDate_ ?? .now }
        set { creationDate_ = newValue}
    }

    var modificationDate: Date {
        modificationDate_ ?? .now
    }

    var formattedCreationDate: String {
        creationDate.formatted(date: .numeric, time: .omitted)
    }

    var status: String {
        if completed {
            NSLocalizedString("Closed", comment: "This issue has been resolved by the user.")
        } else {
            NSLocalizedString("Open", comment: "This issue is currently unresolved.")
        }
    }

    var reminderTime: Date {
        get { reminderTime_ ?? .now }
        set { reminderTime_ = newValue }
    }

    var tagsList: String {
        let noTags = NSLocalizedString("No tags", comment: "The user has not created any tags yet.")
        guard let tags = tags_ else { return noTags}

        if tags.count == 0 {
            return noTags
        } else {
            return sortedTags.map(\.name).formatted()
        }
    }

    var tags: Set<Tag> {
        get { (tags_ as? Set<Tag>) ?? [] }
        set { tags_ = newValue as NSSet }
    }

    var sortedTags: [Tag] {
        (tags_?.allObjects as? [Tag] ?? []).sorted()
    }

    func addToTags(_ tag: Tag) {
        addToTags_(tag)
    }

    func removeFromTags(_ value: Tag) {
        removeFromTags_(value)
    }

    func addToTags(_ values: Set<Tag>) {
        let newValues = (values as NSSet) as NSSet
        addToTags_(newValues)
    }

    func removeFromIssues(_ values: Set<Tag>) {
        let valuesToRemove = (values as NSSet) as NSSet
        removeFromTags_(valuesToRemove)
    }
}

extension Issue: Comparable {
    public static func < (lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.title.localizedLowercase
        let right = rhs.title.localizedLowercase

        if left == right {
            return lhs.creationDate < rhs.creationDate
        } else {
            return left < right
        }
    }
}

extension Issue {
    static var example: Issue {
        let dataManager = DataManager(inMemory: true)
        let viewContext = dataManager.container.viewContext

        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is an exmple issue"
        issue.priority = 2
        issue.creationDate = .now
        return issue
    }
}
