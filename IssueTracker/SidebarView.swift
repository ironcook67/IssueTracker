//
//  SidebarView.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var dataManager: DataManager
    let smartFilters: [Filter] = [.all, .recent]
    
    var body: some View {
        List(selection: $dataManager.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
            }
        }
    }
}

#Preview {
    SidebarView()
}
