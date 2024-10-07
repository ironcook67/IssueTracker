//
//  DataManager-testing.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/6/24.
//

import SwiftUI

extension DataManager {
    func checkForTestingEvironment() {
#if DEBUG
        // Used for UI Testing. Delete all of the data to start with a clean slate
        // and turn off aninmation for faster tests.
        if CommandLine.arguments.contains("enable-testing") {
            self.deleteAll()
#if os(iOS)
            UIView.setAnimationsEnabled(false)
#endif // os(iOS)
        }
#endif  // DEBUG
    }
}

