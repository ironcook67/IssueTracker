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
    
    @State private var tagToRename: Tag?
    @State private var renamingTag = false
    @State private var tagName = ""
    
    @State private var showingAwards = false
    
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
                            .badge(filter.tag?.activeIssues.count ?? 0)
                            .contextMenu {
                                Button {
                                    rename(filter)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                            }
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .toolbar {
            Button(action: dataManager.newTag) {
                Label("Add Tag", systemImage: "plus")
            }
            
            Button {
                showingAwards.toggle()
            } label: {
                Label("Show awards", systemImage: "rosette")
            }
#if DEBUG
            Button {
                dataManager.deleteAll()
                dataManager.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            }
#endif
        }
        .alert("Rename tag", isPresented: $renamingTag) {
            Button("OK", action: completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $tagName)
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)
    }
    
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
            dataManager.delete(item)
        }
    }
    
    func rename(_ filter: Filter) {
        tagToRename = filter.tag
        tagName = filter.name
        renamingTag = true
    }
    
    func completeRename() {
        tagToRename?.name = tagName
        dataManager.save()
    }
}

#Preview {
    SidebarView()
        .environmentObject(DataManager.preview)
}
