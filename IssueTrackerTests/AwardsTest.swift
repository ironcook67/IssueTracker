//
//  AwardsTest.swift
//  IssueTrackerTests
//
//  Created by Chon Torres on 10/7/23.
//

import CoreData
import XCTest
@testable import IssueTracker

final class AwardsTest: BaseTestCase {
    let awards = Award.allAwards

    func testAwardIDMarchesName() {
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Award ID should always match its name.")
        }
    }

    func testNewUserHasUnlockedNoAwards() {
        for award in awards {
            XCTAssertFalse(dataManager.hasEarned(award: award), "New users should have no earned awards.")
        }
    }

    func testCreatingIssuesUnlocksAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {
            var issues = [Issue]()

            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issues.append(issue)
            }

            let matches = awards.filter { award in
                award.criterion == "issues" && dataManager.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, count + 1, "Adding \(value) issues should unlock \(count + 1) awards.")

            dataManager.deleteAll()
        }
    }

    func testClosedAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {
            var issues = [Issue]()

            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issue.completed = true
                issues.append(issue)
            }

            let matches = awards.filter { award in
                award.criterion == "closed" && dataManager.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, count + 1, "Completing \(value) issues should unlock \(count + 1) awards.")

            for issue in issues {
                dataManager.delete(issue)
            }
        }
    }

    func testCreatingTagsUnlocksAwards() {
        let values = [1, 10, 50]

        for (count, value) in values.enumerated() {
            var tags = [Tag]()

            for _ in 0..<value {
                let tag = Tag(context: managedObjectContext)
                tags.append(tag)
            }

            let matches = awards.filter { award in
                award.criterion == "tags" && dataManager.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, count + 1, "Adding \(value) tags should unlock \(count + 1) awards.")

            dataManager.deleteAll()
        }
    }
}
