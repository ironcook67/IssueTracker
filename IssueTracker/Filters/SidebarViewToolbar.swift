//
//  SidebarViewToolbar.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/7/23.
//

import SwiftUI

struct SidebarViewToolbar: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAwards = false
    @State private var showingStore = false

    var body: some View {
        Button(action: tryNewTag) {
            Label("Add tag", systemImage: "plus")
        }
        .sheet(isPresented: $showingStore, content: StoreView.init)
        .help("Add tag")

        Button {
            showingAwards.toggle()
        } label: {
            Label("Show awards", systemImage: "rosette")
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)
        .help("Show awards")

#if DEBUG
        Button {
            dataManager.deleteAll()
            dataManager.createSampleData()
        } label: {
            Label("ADD SAMPLES", systemImage: "flame")
        }
#endif
    }

    func tryNewTag() {
        if dataManager.newTag() == false {
            showingStore = true
        }
    }
}

#Preview {
    SidebarViewToolbar()
        .environmentObject(DataManager(inMemory: true))
}
