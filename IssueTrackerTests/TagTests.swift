//
//  TagTests.swift
//  IssueTrackerTests
//
//  Created by Chon Torres on 10/7/23.
//

import CoreData
import XCTest
@testable import IssueTracker

final class TagTests: BaseTestCase {
    func testCreatingTagsAndIssues() {
        let count = 10
        let issueCount = 10 * 10

        for _ in 0..<count {
            let tag = Tag(context: managedObjectContext)

            for _ in 0..<count {
                let issue = Issue(context: managedObjectContext)
                tag.addToIssues(issue)
            }
        }

        XCTAssertEqual(dataManager.count(for: Tag.fetchRequest()), count, "Expected \(count) tags.")
        XCTAssertEqual(dataManager.count(for: Issue.fetchRequest()), issueCount, "Expected \(issueCount) issues.")
    }

    func testDeletingTagDoesNotDeleteIssue() throws {
        dataManager.createSampleData()

        let request = Tag.fetchRequest()
        let tags = try managedObjectContext.fetch(request)
        dataManager.delete(tags[0])

        XCTAssertEqual(dataManager.count(for: Tag.fetchRequest()), 4, "Expected 4 tags after deleting 1 tag.")
        XCTAssertEqual(dataManager.count(for: Issue.fetchRequest()), 50, "Expected 50 issues after deleting 1 tag.")
    }
}
