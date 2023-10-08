//
//  PerformaceTests.swift
//  IssueTrackerTests
//
//  Created by Chon Torres on 10/7/23.
//

import XCTest
@testable import IssueTracker

final class PerformaceTests: BaseTestCase {
    func testAwardCalculationPerformance() {
        for _ in 1...100 {
            dataManager.createSampleData()
        }

        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500, "This checks the awards count is constant. Change if you add awards")

        measure {
            _ = awards.filter(dataManager.hasEarned)
        }
    }
}
