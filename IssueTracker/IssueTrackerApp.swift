//
//  IssueTrackerApp.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import CoreSpotlight
import SwiftUI

@main
struct IssueTrackerApp: App {
    @StateObject var dataManager = DataManager()
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(dataManager: dataManager)
            } content: {
                ContentView(dataManager: dataManager)
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataManager.container.viewContext)
            .environmentObject(dataManager)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase != .active {
                    dataManager.save()
                }
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        }
    }

    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            dataManager.selectedIssue = dataManager.issue(with: uniqueIdentifier)
            dataManager.selectedFilter = .all
        }
    }
}
