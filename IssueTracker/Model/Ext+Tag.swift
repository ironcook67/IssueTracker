//
//  Ext+Tag.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import Foundation

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
    
    func addToIssues(_ issue: Issue) {
        addToIssues_(issue)
    }
}
