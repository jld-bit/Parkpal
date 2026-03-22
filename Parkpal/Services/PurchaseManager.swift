import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var unlockedProFeatures = false

    private let productIDs = ["com.parkpal.pro.multispot"]

    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error.localizedDescription)")
        }
    }

    func updatePurchasedState() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if productIDs.contains(transaction.productID) {
                unlockedProFeatures = true
                return
            }
        }
        unlockedProFeatures = false
    }

    func purchasePro() async {
        guard let product = products.first else { return }

        do {
            let result = try await product.purchase()
            if case .success(let verification) = result,
               case .verified(let transaction) = verification {
                unlockedProFeatures = true
                await transaction.finish()
            }
        } catch {
            print("Purchase failed: \(error.localizedDescription)")
        }
    }
}
