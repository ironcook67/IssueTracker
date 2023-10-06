//
//  Ext+Tag.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import Foundation
import CoreData

extension Tag {
    var uuid: UUID {
        get { uuid_ ?? UUID() }
        set { uuid_ = newValue }
    }
    
    var name: String {
        get { name_ ?? "No Name" }
        set { name_ = newValue }
    }
    
    var issues: Set<Issue> {
        get { (issues_ as? Set<Issue>) ?? [] }
        set { issues_ = newValue as NSSet }
    }
    
    var activeIssues: [Issue] {
        let result = issues_?.allObjects as? [Issue] ?? []
        return result.filter { $0.completed == false }.sorted()
    }
    
    func addToIssues(_ issue: Issue) {
        addToIssues_(issue)
    }
    
    func removeFromIssues(_ value: Issue) {
        removeFromIssues_(value)
    }
    
    func addToIssues(_ values: Set<Issue>) {
        let newValues = (values as NSSet) as NSSet
        addToIssues_(newValues)
    }
    
    func removeFromIssues(_ values: Set<Issue>) {
        let valuesToRemove = (values as NSSet) as NSSet
        removeFromIssues_(valuesToRemove)
    }
}

extension Tag: Comparable {
    public static func < (lhs: Tag, rhs: Tag) -> Bool {
        let left = lhs.name.localizedLowercase
        let right = rhs.name.localizedLowercase
        
        if left == right {
            return lhs.uuid < rhs.uuid
        } else {
            return left < right
        }
    }
}

extension Tag {
    static var example: Tag {
        let dataManager = DataManager(inMemory: true)
        let viewContext = dataManager.container.viewContext
        
        let tag = Tag(context: viewContext)
        tag.uuid = UUID()
        tag.name = "Example Tag"
        return tag
    }
}
