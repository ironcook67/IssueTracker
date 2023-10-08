//
//  DevelopmentTests.swift
//  IssueTrackerTests
//
//  Created by Chon Torres on 10/7/23.
//

import CoreData
import XCTest
@testable import IssueTracker

final class DevelopmentTests: BaseTestCase {
    func testSampleDataCreationWorks() throws {
        dataManager.createSampleData()

        XCTAssertEqual(dataManager.count(for: Tag.fetchRequest()), 5, "Expected 5 sample data tags.")
        XCTAssertEqual(dataManager.count(for: Issue.fetchRequest()), 50, "Expected 50 sample data issues.")
    }

    func testDeleteAllDeletedEverything() {
        dataManager.createSampleData()
        dataManager.deleteAll()

        XCTAssertEqual(dataManager.count(for: Tag.fetchRequest()), 0, "Expected 0 tags after deleteAll.")
        XCTAssertEqual(dataManager.count(for: Issue.fetchRequest()), 0, "Expected 0 samples after deleteAll.")
    }

    func testExampleTagHasNoIssues() {
        let tag = Tag.example
        XCTAssertEqual(tag.issues_?.count, 0, "The example tag should have 0 issues.")
    }

    func testExampleIssueIsHighPriority() {
        let issue = Issue.example
        XCTAssertEqual(issue.priority, 2, "The example issue should be high priority.")
    }
}
