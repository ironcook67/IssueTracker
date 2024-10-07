//
//  SidebarView.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import SwiftUI

struct SidebarView: View {
    @StateObject private var viewModel: ViewModel
    let smartFilters: [Filter] = [.all, .recent]

    init(dataManager: DataManager) {
        let viewModel = ViewModel(dataManager: dataManager)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(selection: $viewModel.dataManager.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters, content: SmartFilterRow.init)
            }

            Section("Tags") {
                ForEach(viewModel.tagFilters) { filter in
                    UserFilterRow(filter: filter, rename: viewModel.rename, delete: viewModel.delete)
                }
                .onDelete(perform: viewModel.delete)
            }
        }
        .macFrame(minWidth: 220)
        .toolbar(content: SidebarViewToolbar.init)
        .alert("Rename tag", isPresented: $viewModel.renamingTag) {
            Button("OK", action: viewModel.completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $viewModel.tagName)
        }
        .navigationTitle("Filters")
    }
}

#Preview {
    NavigationStack {
        SidebarView(dataManager: DataManager.preview)
    }
}
