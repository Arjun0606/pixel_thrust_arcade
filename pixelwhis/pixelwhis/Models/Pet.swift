import Foundation
import SwiftData

enum PetStage: String, Codable {
    case egg
    case baby
    case child
    case teen
    case adult
    case elder
}

enum PetState: String, Codable {
    case normal
    case sleeping
    case sick
    case runaway // The "Neglect" penalty
    case hibernating // If ignored for too long but not runaway? Or maybe just runaway.
}

@Model
final class Pet {
    var name: String
    var birthDate: Date
    var lastInteractionDate: Date
    
    // Stats (0-100)
    var hunger: Int
    var happiness: Int
    var energy: Int
    var health: Int
    
    // Evolution
    var stage: PetStage
    var experience: Int
    
    // State
    var state: PetState
    var runawayDate: Date? // When they ran away
    
    // Dynamic DNA
    var dna: PetDNA?
    var currentSpriteURL: String? // Cached sprite for current stage
    
    init(name: String = "Pixel", dna: PetDNA? = nil) {
        self.name = name
        self.birthDate = Date()
        self.lastInteractionDate = Date()
        
        self.hunger = 100
        self.happiness = 100
        self.energy = 100
        self.health = 100
        
        self.stage = .egg
        self.experience = 0
        self.state = .normal
        self.dna = dna
    }
    
    var isRunaway: Bool {
        return state == .runaway
    }
    
    // Logic to check if should run away
    func checkNeglect() {
        if hunger <= 0 && happiness <= 0 {
            self.state = .runaway
            self.runawayDate = Date()
        }
    }
}
