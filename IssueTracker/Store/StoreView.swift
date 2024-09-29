//
//  StoreView.swift
//  IssueTracker
//
//  Created by Chon Torres on 9/27/24.
//

import StoreKit
import SwiftUI

struct StoreView: View {
    enum LoadState {
        case loading, loaded, error
    }

    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss

    @State private var loadState = LoadState.loading
    @State private var showingPurchaseError: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack {
                    Image(decorative: "unlock")
                        .resizable()
                        .scaledToFit()

                    Text("Upgrade Today!")
                        .font(.title.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)

                    Text("Get the most out of the app")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(.blue.gradient)

                ScrollView {
                    VStack {
                        switch loadState {
                        case .loading:
                            Text("Fetching offers…")
                                .font(.title2.bold())
                                .padding(.top, 50)

                            ProgressView()
                                .controlSize(.large)

                        case .loaded:
                            ForEach(dataManager.products) { product in
                                VStack(alignment: .leading) {
                                    Button {
                                        purchase(product)
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(product.displayName)
                                                    .font(.title2.bold())

                                                Text(product.description)
                                            }

                                            Spacer()

                                            Text(product.displayPrice)
                                                .font(.title)
                                                .fontDesign(.rounded)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(.gray.opacity(0.2), in: .rect(cornerRadius: 20))
                                        .contentShape(.rect)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                        case .error:
                            Text("Sorry, there was an error loading our store.")
                                .padding(.top, 50)

                            Button("Try Again") {
                                Task {
                                    await load()
                                }
                            }
                            .buttonStyle(.borderedProminent)

                        }
                    }
                    .padding(20)
                }

                Button("Restore Purchases", action: restore)

                Button("Cancel") {
                    dismiss()
                }
                .padding(.top, 20)
            }
        }
        .alert("In-app purchases are disabled", isPresented: $showingPurchaseError) {
        } message: {
            Text("""
                You can't purchase the premium unlock because in-app purchases are disabled on this device.
            
                Please ask whomever manages your device for assistance."
            """)
        }
        .onChange(of: dataManager.fullVersionUnlocked) { _, _ in
            checkForPurchase()
        }
        .task {
            await load()
        }
    }

    func checkForPurchase() {
        if dataManager.fullVersionUnlocked {
            dismiss()
        }
    }

    func purchase(_ product: Product) {
        guard AppStore.canMakePayments else {
            showingPurchaseError = true
            return
        }

        Task { @MainActor in
            try await dataManager.purchase(product)
        }
    }

    func load() async {
        loadState = .loading

        do {
            try await dataManager.loadProducts()

            if dataManager.products.isEmpty {
                loadState = .error
            } else {
                loadState = .loaded
            }
        } catch {
            loadState = .error
        }
    }

    func restore() {
        Task {
            try await AppStore.sync()
        }
    }
}

#Preview {
    StoreView()
}
