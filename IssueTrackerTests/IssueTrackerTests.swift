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
}
