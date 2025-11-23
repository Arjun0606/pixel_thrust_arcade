import Foundation

struct DailyDeal {
    let product: IAPProduct
    let discount: Double // 0.0 to 1.0
    let expiryDate: Date
    let isLimitedQuantity: Bool
    let remainingQuantity: Int?
    
    var discountedPrice: Double {
        product.basePrice * (1.0 - discount)
    }
    
    var isExpired: Bool {
        Date() > expiryDate
    }
    
    var isSoldOut: Bool {
        if let qty = remainingQuantity {
            return qty <= 0
        }
        return false
    }
}

class DailyDealsManager {
    static let shared = DailyDealsManager()
    
    private let dealsKey = "daily_deals_date"
    
    func getTodaysDeals() -> [DailyDeal] {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDealsDate = UserDefaults.standard.object(forKey: dealsKey) as? Date ?? Date.distantPast
        
        // Check if deals need refresh
        if !Calendar.current.isDate(lastDealsDate, inSameDayAs: today) {
            UserDefaults.standard.set(today, forKey: dealsKey)
        }
        
        // Generate pseudo-random deals based on date seed
        let seed = Int(today.timeIntervalSince1970 / 86400)
        var rng = SeededRandom(seed: seed)
        
        return [
            // Deal 1: Gem pack with big discount
            DailyDeal(
                product: [.gemsBag, .gemsChest, .gemsMountain][rng.next() % 3],
                discount: 0.4, // 40% off
                expiryDate: today.addingTimeInterval(86400),
                isLimitedQuantity: true,
                remainingQuantity: 50
            ),
            // Deal 2: Bundle at discounted price
            DailyDeal(
                product: [.starterBundle, .growthBundle][rng.next() % 2],
                discount: 0.3, // 30% off
                expiryDate: today.addingTimeInterval(86400),
                isLimitedQuantity: false,
                remainingQuantity: nil
            ),
            // Deal 3: Convenience item
            DailyDeal(
                product: [.instantEvolution, .autoFeeder][rng.next() % 2],
                discount: 0.25, // 25% off
                expiryDate: today.addingTimeInterval(86400),
                isLimitedQuantity: true,
                remainingQuantity: 100
            )
        ]
    }
}

// Simple seeded RNG for consistent daily deals
struct SeededRandom {
    private var state: UInt64
    
    init(seed: Int) {
        state = UInt64(seed)
    }
    
    mutating func next() -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Int(state >> 32)
    }
}
