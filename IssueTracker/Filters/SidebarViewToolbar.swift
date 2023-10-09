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

    var body: some View {
        Button(action: dataManager.newTag) {
            Label("Add tag", systemImage: "plus")
        }

        Button {
            showingAwards.toggle()
        } label: {
            Label("Show awards", systemImage: "rosette")
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)

#if DEBUG
        Button {
            dataManager.deleteAll()
            dataManager.createSampleData()
        } label: {
            Label("ADD SAMPLES", systemImage: "flame")
        }
#endif
    }
}

#Preview {
    SidebarViewToolbar()
        .environmentObject(DataManager(inMemory: true))
}
