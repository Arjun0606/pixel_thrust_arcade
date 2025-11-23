import Foundation
import SwiftData

@Model
final class PlayerWallet {
    // Soft currency (earned through gameplay)
    var coins: Int
    
    // Hard currency (IAP only, or very rare rewards)
    var gems: Int
    
    // Energy system (interactions cost energy)
    var energy: Int
    var maxEnergy: Int
    var lastEnergyRefill: Date
    
    // Pro status
    var isProUser: Bool
    var proExpiryDate: Date?
    
    // Purchase history (for daily deals)
    var lastPurchaseDate: Date?
    var totalSpent: Double
    
    init() {
        self.coins = 100 // Starting coins
        self.gems = 10 // Starting gems
        self.energy = 100
        self.maxEnergy = 100
        self.lastEnergyRefill = Date()
        self.isProUser = false
        self.totalSpent = 0
    }
    
    func refillEnergy() {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastEnergyRefill)
        let energyToAdd = Int(elapsed / 300) // 1 energy per 5 minutes
        
        if energyToAdd > 0 {
            energy = min(maxEnergy, energy + energyToAdd)
            lastEnergyRefill = now
        }
    }
    
    func canAfford(coins: Int = 0, gems: Int = 0, energy: Int = 0) -> Bool {
        return self.coins >= coins && self.gems >= gems && self.energy >= energy
    }
    
    func spend(coins: Int = 0, gems: Int = 0, energy: Int = 0) {
        self.coins -= coins
        self.gems -= gems
        self.energy -= energy
    }
    
    func earn(coins: Int = 0, gems: Int = 0) {
        self.coins += coins
        self.gems += gems
    }
    
    func useEnergy(_ amount: Int) -> Bool {
        refillEnergy()
        if canAfford(energy: amount) {
            spend(energy: amount)
            return true
        }
        return false
    }
}
