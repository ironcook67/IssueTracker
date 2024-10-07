//
//  AwardsView.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/6/23.
//

import SwiftUI

struct AwardsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss

    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false

    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(color(for: award))
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel(label(for: award))
                        .accessibilityHint(award.description)
                    }
                }
            }
            .navigationTitle("Awards")
#if !os(watchOS)
            .toolbar {
                Button("Close") {
                    dismiss()
                }
            }
#endif // !os(watchOS)
        }
        .macFrame(minWidth: 600, maxHeight: 500)
        .alert(awardTitle, isPresented: $showingAwardDetails) {
        } message: {
            Text(selectedAward.description)
        }
    }

    var awardTitle: LocalizedStringKey {
        if dataManager.hasEarned(award: selectedAward) {
            return "Unlocked \(selectedAward.name)"
        } else {
            return "Locked"
        }
    }

    func color(for award: Award) -> Color {
        dataManager.hasEarned(award: award) ? Color(award.color) : .secondary.opacity(0.5)
    }

    func label(for award: Award) -> LocalizedStringKey {
        dataManager.hasEarned(award: award) ? "Unlocked \(award.name)" : "Locked"
    }
}

#Preview {
    AwardsView()
        .environmentObject(DataManager(inMemory: true))
}
