import Foundation
import StoreKit

enum IAPProduct: String, CaseIterable {
    // SUBSCRIPTIONS
    case proMonthly = "com.pixelgotchi.pro.monthly"
    
    // CURRENCY PACKS (Gems)
    case gemsPile = "com.pixelgotchi.gems.pile" // 100 gems - $0.99
    case gemsBag = "com.pixelgotchi.gems.bag" // 500 gems - $4.99
    case gemsChest = "com.pixelgotchi.gems.chest" // 1200 gems - $9.99 (20% bonus)
    case gemsMountain = "com.pixelgotchi.gems.mountain" // 3000 gems - $19.99 (50% bonus)
    
    // ENERGY REFILLS
    case energyRefillSmall = "com.pixelgotchi.energy.small" // 50 energy - $0.99
    case energyRefillFull = "com.pixelgotchi.energy.full" // Full refill - $1.99
    
    // CONVENIENCE
    case instantEvolution = "com.pixelgotchi.evolution.instant" // $2.99
    case petRescue = "com.pixelgotchi.rescue" // $0.99
    case autoFeeder = "com.pixelgotchi.autofeeder.24h" // 24h auto-feed - $1.99
    
    // COSMETICS
    case traitPack = "com.pixelgotchi.traits.pack" // Random trait - $1.99
    case rareTraitPack = "com.pixelgotchi.traits.rare" // Rare trait guaranteed - $4.99
    case accessoryPack = "com.pixelgotchi.accessory.pack" // Outfit bundle - $3.99
    
    // BUNDLES (Best Value)
    case starterBundle = "com.pixelgotchi.bundle.starter" // 500 gems + trait pack - $4.99
    case growthBundle = "com.pixelgotchi.bundle.growth" // Instant evolution + 1200 gems - $9.99
    case premiumBundle = "com.pixelgotchi.bundle.premium" // Pro 1 month + 3000 gems - $14.99
    
    var basePrice: Double {
        switch self {
        case .proMonthly: return 4.99
        case .gemsPile: return 0.99
        case .gemsBag: return 4.99
        case .gemsChest: return 9.99
        case .gemsMountain: return 19.99
        case .energyRefillSmall: return 0.99
        case .energyRefillFull: return 1.99
        case .instantEvolution: return 2.99
        case .petRescue: return 0.99
        case .autoFeeder: return 1.99
        case .traitPack: return 1.99
        case .rareTraitPack: return 4.99
        case .accessoryPack: return 3.99
        case .starterBundle: return 4.99
        case .growthBundle: return 9.99
        case .premiumBundle: return 14.99
        }
    }
    
    var proPrice: Double {
        basePrice * 0.5 // 50% off for Pro users
    }
    
    var displayName: String {
        switch self {
        case .proMonthly: return "Pro Monthly"
        case .gemsPile: return "Pile of Gems"
        case .gemsBag: return "Bag of Gems"
        case .gemsChest: return "Chest of Gems"
        case .gemsMountain: return "Mountain of Gems"
        case .energyRefillSmall: return "Energy Boost"
        case .energyRefillFull: return "Full Energy"
        case .instantEvolution: return "Instant Evolution"
        case .petRescue: return "Emergency Rescue"
        case .autoFeeder: return "Auto-Feeder (24h)"
        case .traitPack: return "Trait Pack"
        case .rareTraitPack: return "Rare Trait Pack"
        case .accessoryPack: return "Accessory Bundle"
        case .starterBundle: return "Starter Bundle"
        case .growthBundle: return "Growth Bundle"
        case .premiumBundle: return "Premium Bundle"
        }
    }
    
    var description: String {
        switch self {
        case .proMonthly: return "Unlimited generations, 50% off IAPs, faster evolution"
        case .gemsPile: return "100 Gems"
        case .gemsBag: return "500 Gems"
        case .gemsChest: return "1200 Gems (+20% bonus!)"
        case .gemsMountain: return "3000 Gems (+50% bonus!)"
        case .energyRefillSmall: return "+50 Energy"
        case .energyRefillFull: return "Full Energy Refill"
        case .instantEvolution: return "Skip to next stage instantly"
        case .petRescue: return "Bring your pet home now"
        case .autoFeeder: return "Auto-feed every 6 hours for 24h"
        case .traitPack: return "Random special trait"
        case .rareTraitPack: return "Guaranteed rare trait"
        case .accessoryPack: return "3 random outfits"
        case .starterBundle: return "500 Gems + Trait Pack (Save 33%!)"
        case .growthBundle: return "Instant Evolution + 1200 Gems (Save 40%!)"
        case .premiumBundle: return "Pro 1mo + 3000 Gems (Save 60%!)"
        }
    }
    
    var category: IAPCategory {
        switch self {
        case .proMonthly: return .subscription
        case .gemsPile, .gemsBag, .gemsChest, .gemsMountain: return .currency
        case .energyRefillSmall, .energyRefillFull: return .energy
        case .instantEvolution, .petRescue, .autoFeeder: return .convenience
        case .traitPack, .rareTraitPack, .accessoryPack: return .cosmetics
        case .starterBundle, .growthBundle, .premiumBundle: return .bundles
        }
    }
}

enum IAPCategory: String {
    case subscription = "Subscription"
    case currency = "Gems"
    case energy = "Energy"
    case convenience = "Convenience"
    case cosmetics = "Cosmetics"
    case bundles = "Bundles"
}
