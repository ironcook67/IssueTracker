//
//  DataManager-Awards.swift
//  IssueTracker
//
//  Created by Chon Torres on 9/29/24.
//

import Foundation

extension DataManager {
    // MARK: - Awards
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "issues":
            // return true if they added a certain nnumber of issues
            let fetchRequest = Issue.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "closed":
            // return true if they closed a certain number of issues
            let fetchRequest = Issue.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "completed == true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "tags":
            // return true if they created a certain number of tags
            let fetchRequest = Tag.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "unlock":
            return fullVersionUnlocked

        default:
            // unknown award criterion. This should never happen.
            //            fatalError("Unknown award criterion \(award.criterion)")
            return false
        }
    }
}
