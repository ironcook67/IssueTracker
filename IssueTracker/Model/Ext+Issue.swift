//
//  Ext+Issue.swift
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
    
    var tags: Set<Tag> {
        get { (tags_ as? Set<Tag>) ?? [] }
        set { tags_ = newValue as NSSet }
    }
    
    func addToTags(_ tag: Tag) {
        addToTags_(tag)
    }
}
