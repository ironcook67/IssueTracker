//
//  DataManager-StoreKit.swift
//  IssueTracker
//
//  Created by Chon Torres on 9/27/24.
//

import Foundation
import StoreKit

extension DataManager {
    /// The product id for our premium unlock.
    static let unlockPremiumProductId: String = "com.chontorres.issueTracker.premiumUnlock"

    /// Loads and saves whether our premium unlock has been purchased.
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }

        set {
            defaults.set(newValue, forKey: "fullVersionUnlocked")
        }
    }

    func monitorTransactions() async {
        // check for previous purchases
        for await entitlement in Transaction.currentEntitlements {
            if case let .verified(transaction) = entitlement {
                await finalize(transaction)
            }
        }

        // Watch for future transactions coming in
        for await update in Transaction.updates {
            if let transaction = try? update.payloadValue {
                await finalize(transaction)
            }
        }
    }

#if !os(visionOS)
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        if case let .success(validation) = result {
            try await finalize(validation.payloadValue)
        }
    }
#endif // !os(visionOS)

    @MainActor
    func finalize(_ transaction: Transaction) async {
        if transaction.productID == Self.unlockPremiumProductId {
            objectWillChange.send()
            fullVersionUnlocked = transaction.revocationDate == nil
            await transaction.finish()
        }
    }

    @MainActor
    func loadProducts() async throws {
        guard products.isEmpty else { return }

        try await Task.sleep(for: .seconds(0.2))
        products = try await Product.products(for: [Self.unlockPremiumProductId])
    }
}
