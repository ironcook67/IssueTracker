//
//  Issue+Ext.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import Foundation

extension Issue {
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
        get { modificationDate_ ?? .now }
        set { modificationDate_ = newValue}
    }
    
    var status: String {
        completed ? "Closed" : "Open"
    }
    
    var tagsList: String {
        guard let tags = tags_ else { return "No tags"}
        
        if tags.count == 0 {
            return "No tags"
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
