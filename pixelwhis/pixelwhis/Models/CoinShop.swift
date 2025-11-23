import Foundation

// Coin shop items (purchasable with soft currency)
enum CoinShopItem: String, CaseIterable {
    case energyRefill = "energy_refill_coins"
    case instantFeed = "instant_feed"
    case instantPlay = "instant_play"
    case evolutionBoost = "evolution_boost"
    case gemExchange = "gem_exchange"
    
    var name: String {
        switch self {
        case .energyRefill: return "Energy Refill"
        case .instantFeed: return "Instant Feed"
        case .instantPlay: return "Instant Play"
        case .evolutionBoost: return "Evolution Boost"
        case .gemExchange: return "Convert to Gems"
        }
    }
    
    var description: String {
        switch self {
        case .energyRefill: return "+25 Energy (no wait!)"
        case .instantFeed: return "Feed without energy cost"
        case .instantPlay: return "Play without energy cost"
        case .evolutionBoost: return "+50 XP towards evolution"
        case .gemExchange: return "Exchange 500 coins for 1 gem"
        }
    }
    
    var coinCost: Int {
        switch self {
        case .energyRefill: return 50 // Cheaper than IAP but still meaningful
        case .instantFeed: return 20
        case .instantPlay: return 30
        case .evolutionBoost: return 100
        case .gemExchange: return 500 // Terrible rate to drive gem purchases
        }
    }
    
    var icon: String {
        switch self {
        case .energyRefill: return "bolt.fill"
        case .instantFeed: return "fork.knife"
        case .instantPlay: return "gamecontroller.fill"
        case .evolutionBoost: return "arrow.up.circle.fill"
        case .gemExchange: return "arrow.triangle.2.circlepath"
        }
    }
    
    var color: String {
        switch self {
        case .energyRefill: return "orange"
        case .instantFeed: return "orange"
        case .instantPlay: return "pink"
        case .evolutionBoost: return "purple"
        case .gemExchange: return "cyan"
        }
    }
}

extension PlayerWallet {
    func purchaseCoinItem(_ item: CoinShopItem, for pet: Pet?) -> Bool {
        guard canAfford(coins: item.coinCost) else { return false }
        
        spend(coins: item.coinCost)
        
        // Apply item effect
        switch item {
        case .energyRefill:
            energy = min(maxEnergy, energy + 25)
        case .instantFeed:
            if let pet = pet {
                pet.hunger = min(100, pet.hunger + 30)
                pet.experience += 5
            }
        case .instantPlay:
            if let pet = pet {
                pet.happiness = min(100, pet.happiness + 20)
                pet.experience += 10
            }
        case .evolutionBoost:
            if let pet = pet {
                pet.experience += 50
            }
        case .gemExchange:
            earn(gems: 1)
        }
        
        return true
    }
}
