//
//  IssueTrackerTests.swift
//  IssueTrackerTests
//
//  Created by Chon Torres on 10/7/23.
//

import CoreData
import XCTest
@testable import IssueTracker

class BaseTestCase: XCTestCase {
    var dataManager: DataManager!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataManager = DataManager(inMemory: true)
        managedObjectContext = dataManager.container.viewContext
    }

    func testSampleDataCreation() throws {
        dataManager.createSampleData()

        XCTAssertEqual(dataManager.count(for: Tag.fetchRequest()), 5, "Expected 5 tags in our sample data.")
        XCTAssertEqual(dataManager.count(for: Issue.fetchRequest()), 50, "Expected 50 issues in our sample data.")
    }
}
