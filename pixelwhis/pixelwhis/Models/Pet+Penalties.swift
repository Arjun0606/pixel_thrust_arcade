import Foundation
import SwiftData

// Pet penalty states
enum PetPenaltyState: String, Codable {
    case healthy
    case sick // Stats dropped below 20
    case hibernating // Neglected for 12+ hours
    case critical // About to die/run away permanently
}

extension Pet {
    var penaltyState: PetPenaltyState {
        // Check for hibernation (most severe)
        let hoursSinceInteraction = Date().timeIntervalSince(lastInteractionDate) / 3600
        
        if hoursSinceInteraction >= 24 {
            return .critical
        } else if hoursSinceInteraction >= 12 {
            return .hibernating
        }
        
        // Check for sickness
        if hunger < 20 || happiness < 20 || health < 20 {
            return .sick
        }
        
        return .healthy
    }
    
    var canInteract: Bool {
        switch penaltyState {
        case .healthy:
            return !isRunaway
        case .sick:
            return false // Need to cure first
        case .hibernating, .critical:
            return false // Need to wake up first
        }
    }
    
    var recoveryTimeRemaining: TimeInterval? {
        let sickDate = lastInteractionDate
        
        switch penaltyState {
        case .healthy:
            return nil
        case .sick:
            // 6 hours to recover naturally (Pro: 3 hours)
            let recoveryDuration: TimeInterval = 6 * 3600
            let elapsed = Date().timeIntervalSince(sickDate)
            return max(0, recoveryDuration - elapsed)
        case .hibernating:
            // 12 hours to wake up (Pro: 6 hours)
            let lastInteraction = lastInteractionDate
            let recoveryDuration: TimeInterval = 12 * 3600
            let elapsed = Date().timeIntervalSince(lastInteraction)
            return max(0, recoveryDuration - elapsed)
        case .critical:
            // 24 hours to auto-recover (Pro: 12 hours) or pay
            let lastInteraction = lastInteractionDate
            let recoveryDuration: TimeInterval = 24 * 3600
            let elapsed = Date().timeIntervalSince(lastInteraction)
            return max(0, recoveryDuration - elapsed)
        }
    }
    
    func getRecoveryTimeString(isPro: Bool) -> String {
        guard let remaining = recoveryTimeRemaining else { return "" }
        
        var actualRemaining = remaining
        if isPro {
            actualRemaining = remaining / 2 // Pro gets half recovery time
        }
        
        let hours = Int(actualRemaining / 3600)
        let minutes = Int((actualRemaining.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // Apply additional penalties for neglect
    func applyNeglectPenalties() {
        let lastInteraction = lastInteractionDate
        
        let hoursSinceInteraction = Date().timeIntervalSince(lastInteraction) / 3600
        
        // Accelerating stat decay (exponential)
        if hoursSinceInteraction > 6 {
            let decayMultiplier = min(5.0, pow(1.2, hoursSinceInteraction - 6))
            hunger = max(0, hunger - Int(2 * decayMultiplier))
            happiness = max(0, happiness - Int(2 * decayMultiplier))
            energy = max(0, energy - Int(1 * decayMultiplier))
        }
        
        // XP loss penalty (lose progress if neglected too long)
        if hoursSinceInteraction > 24 {
            let xpLoss = Int(hoursSinceInteraction - 24) * 5
            experience = max(0, experience - xpLoss)
        }
    }
}
