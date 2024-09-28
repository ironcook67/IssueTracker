//
//  StoreView.swift
//  IssueTracker
//
//  Created by Chon Torres on 9/27/24.
//

import StoreKit
import SwiftUI

struct StoreView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var products = [Product]()

    var body: some View {
        NavigationStack {
            if let product = products.first {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.title)

                    Text(product.description)

                    Button("Buy Now") {
                        purchase(product)
                    }
                }
            }
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
        Task { @MainActor in
            try await dataManager.purchase(product)
        }
    }

    func load() async {
        print("Load")
        do {
            products = try await Product.products(for: [DataManager.unlockPremiumProductId])
            print("PRODUCT COUNT", products.count)
        } catch {
            print("Failed to load products: \(error.localizedDescription)")
        }
    }
}

#Preview {
    StoreView()
}
