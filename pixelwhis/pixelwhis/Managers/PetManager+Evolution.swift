import Foundation
import SwiftData

extension PetManager {
    @MainActor
    func checkEvolution(pet: Pet) {
        let requiredXP = getRequiredXP(for: pet.stage)
        
        if pet.experience >= requiredXP {
            // Evolve to next stage
            switch pet.stage {
            case .egg:
                if pet.experience >= 50 {
                    evolve(pet: pet, to: .baby)
                }
            case .baby:
                if pet.experience >= 150 {
                    evolve(pet: pet, to: .child)
                }
            case .child:
                if pet.experience >= 300 {
                    evolve(pet: pet, to: .teen)
                }
            case .teen:
                if pet.experience >= 500 {
                    evolve(pet: pet, to: .adult)
                }
            case .adult:
                if pet.experience >= 750 {
                    evolve(pet: pet, to: .elder)
                }
            case .elder:
                break // Max level
            }
        }
    }
    
    @MainActor
    private func evolve(pet: Pet, to stage: PetStage) {
        pet.stage = stage
        pet.health = 100
        pet.happiness = min(100, pet.happiness + 20)
        
        // Generate evolution message via Gemini
        Task {
            do {
                let message = "I'm evolving! I feel so different... 🌟"
                // Could call Gemini here for personalized message
                print("Evolution: \(pet.name) evolved to \(stage.rawValue)!")
            } catch {
                print("Failed to generate evolution message")
            }
        }
        
        saveAndReload()
    }
    
    private func getRequiredXP(for stage: PetStage) -> Int {
        switch stage {
        case .egg: return 50
        case .baby: return 150
        case .child: return 300
        case .teen: return 500
        case .adult: return 750
        case .elder: return Int.max
        }
    }
}
