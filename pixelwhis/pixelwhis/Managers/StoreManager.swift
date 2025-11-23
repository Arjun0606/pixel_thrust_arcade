import Foundation
import StoreKit
import Combine

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isPro: Bool = false
    
    // Product IDs
    private let proSubscriptionID = "com.pixelgotchi.pro"
    private let rescueConsumableID = "com.pixelgotchi.rescue"
    
    init() {
        // Start listening for transaction updates
        Task {
            for await result in Transaction.updates {
                await handle(transactionVerification: result)
            }
        }
    }
    
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [proSubscriptionID, rescueConsumableID])
            self.products = products
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await handle(transaction: transaction)
            await transaction.finish()
            return true
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }
    
    // Helper for the "Rescue" button
    func purchaseRescue() async throws -> Bool {
        guard let product = products.first(where: { $0.id == rescueConsumableID }) else {
            // For prototype/debug without StoreKit config, we mock success
            print("Debug: Rescue product not found (no StoreKit config). Mocking success.")
            return true
        }
        return try await purchase(product)
    }
    
    private func handle(transactionVerification result: VerificationResult<Transaction>) async {
        do {
            let transaction = try checkVerified(result)
            await handle(transaction: transaction)
            await transaction.finish()
        } catch {
            print("Transaction verification failed")
        }
    }
    
    private func handle(transaction: Transaction) async {
        purchasedProductIDs.insert(transaction.productID)
        if transaction.productID == proSubscriptionID {
            isPro = true
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    enum StoreError: Error {
        case failedVerification
    }
}
