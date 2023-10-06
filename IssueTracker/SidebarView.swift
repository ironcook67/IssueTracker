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
    
    // TODO: Push this into Tags
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name_)]) var tags: FetchedResults<Tag>
    
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.uuid, name: tag.name, icon: "tag", tag: tag)
        }
    }
    
    var body: some View {
        List(selection: $dataManager.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
            }
            
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
            }
        }
        .toolbar {
            Button {
                dataManager.deleteAll()
                dataManager.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            }
        }
    }
}

#Preview {
    SidebarView()
        .environmentObject(DataManager.preview)
}
