//
//  IssueTrackerApp.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import SwiftUI

@main
struct IssueTrackerApp: App {
    @StateObject var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataManager.container.viewContext)
            .environmentObject(dataManager)
        }
    }
}
