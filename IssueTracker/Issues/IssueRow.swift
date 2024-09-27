//
//  IssueRow.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import SwiftUI

struct IssueRow: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject var viewModel: ViewModel

    init(issue: Issue) {
        let viewModel = ViewModel(issue: issue)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationLink(value: viewModel.issue) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(viewModel.iconOpacity)
                    .accessibilityIdentifier(viewModel.iconIdentifier)

                VStack(alignment: .leading) {
                    Text(viewModel.title)
                        .font(.headline)
                        .lineLimit(1)

                    Text(viewModel.tagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(viewModel.creationDate)
                        .accessibilityLabel(viewModel.accessibilityCreationDate)
                        .font(.subheadline)

                    if viewModel.issue.completed {
                        Text("CLOSED")
                            .font(.body.smallCaps())
                    }
                }
            }
            .foregroundStyle(.secondary)
        }
        .accessibilityHint(viewModel.accessibilityHint)
        .accessibilityIdentifier(viewModel.title)
    }
}

#Preview {
    IssueRow(issue: .example)
        .environmentObject(DataManager(inMemory: true))
}
