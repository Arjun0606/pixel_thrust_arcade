import Foundation
import SwiftData
import WidgetKit
#if canImport(UIKit)
import UIKit
#endif

class PetManager {
    static let shared = PetManager()
    
    let container: ModelContainer
    
    init() {
        do {
            // Use default container for MVP. In production, use .init(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false, groupContainer: .identifier("group.com.yourname.PixelGotchi")))
            container = try ModelContainer(for: Pet.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    // Decay rates (per hour)
    private let hungerDecayRate = 5
    private let happinessDecayRate = 5
    private let energyDecayRate = 2
    
    @MainActor
    func feed(pet: Pet, wallet: PlayerWallet) -> Bool {
        // Check energy
        guard wallet.useEnergy(10) else { return false }
        
        pet.hunger = min(100, pet.hunger + 20)
        pet.experience += 10
        pet.lastInteractionDate = Date()
        
        // Earn coins
        wallet.earn(coins: 5)
        
        // Feedback
        SoundManager.shared.playSFX("coin")
        #if canImport(UIKit)
        SoundManager.shared.playHaptic(.medium)
        #else
        SoundManager.shared.playHaptic(1)
        #endif
        
        checkEvolution(pet: pet)
        saveAndReload()
        return true
    }
    
    @MainActor
    func play(pet: Pet, wallet: PlayerWallet) -> Bool {
        guard wallet.useEnergy(15) else { return false }
        
        pet.happiness = min(100, pet.happiness + 25)
        pet.experience += 15
        pet.lastInteractionDate = Date()
        
        wallet.earn(coins: 10)
        
        SoundManager.shared.playSFX("coin")
        #if canImport(UIKit)
        SoundManager.shared.playHaptic(.heavy)
        #else
        SoundManager.shared.playHaptic(2)
        #endif
        
        checkEvolution(pet: pet)
        saveAndReload()
        return true
    }
    
    @MainActor
    func clean(pet: Pet, wallet: PlayerWallet) -> Bool {
        guard !pet.isRunaway else { return false }
        
        // Check energy cost
        guard wallet.useEnergy(5) else { return false }
        wallet.earn(coins: 3)
        
        pet.health = min(100, pet.health + 10)
        pet.lastInteractionDate = Date()
        
        saveAndReload()
        return true
    }
    
    @MainActor
    func rescuePet(pet: Pet) {
        // Paid feature logic would trigger this
        pet.state = .normal
        pet.runawayDate = nil
        pet.hunger = 50
        pet.happiness = 50
        pet.health = 50
        
        saveAndReload()
    }
    
    @MainActor
    func updateStats(pet: Pet) {
        let now = Date()
        let timeSinceLastUpdate = now.timeIntervalSince(pet.lastInteractionDate)
        
        // Apply base stat decay (every 5 minutes)
        if timeSinceLastUpdate >= 300 {
            pet.hunger = max(0, pet.hunger - hungerDecayRate)
            pet.happiness = max(0, pet.happiness - happinessDecayRate)
            pet.energy = max(0, pet.energy - energyDecayRate)
        }
        
        // Apply neglect penalties (accelerating decay, XP loss)
        pet.applyNeglectPenalties()
        
        // Check if pet should enter penalty states
        pet.checkNeglect()
        
        saveAndReload()
    }
    
    func saveAndReload() {
        // In a real app, we'd save the context here.
        // Since we are using SwiftData injected in the View, autosave handles most.
        // But for Widgets, we need to be explicit if using a shared ModelContainer.
        
        WidgetCenter.shared.reloadAllTimelines()
    }
}
