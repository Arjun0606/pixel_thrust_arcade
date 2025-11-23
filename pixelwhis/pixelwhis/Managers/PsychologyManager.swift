import Foundation
import UserNotifications

class PsychologyManager {
    static let shared = PsychologyManager()
    
    // MARK: - Loss Aversion (The Hostage)
    func checkCriticalState(pet: Pet) {
        if pet.penaltyState == .critical {
            // Schedule aggressive notifications
            scheduleNotification(
                title: "🚨 FINAL WARNING",
                body: "\(pet.name) is packing their bags. You have 2 hours left to save them!",
                timeInterval: 1
            )
        }
    }
    
    // MARK: - Variable Rewards (The Slot Machine)
    func checkForMysteryGift() -> Bool {
        // 0.1% chance per second (approx once every 15-20 mins of active play)
        // This makes it rare and exciting
        let roll = Int.random(in: 1...1000)
        return roll == 1
    }
    
    func openMysteryGift() -> (String, Int) {
        let roll = Int.random(in: 1...100)
        if roll <= 80 {
            return ("Coins", Int.random(in: 10...50))
        } else if roll <= 99 {
            return ("Energy", Int.random(in: 10...30))
        } else {
            return ("Gem", 1) // The Jackpot
        }
    }
    
    // MARK: - Artificial Scarcity (The Velvet Rope)
    func generateFlashSale() -> DailyDeal? {
        // Create a fake "limited time" deal
        return DailyDeal(
            product: .rareTraitPack,
            discount: 0.5,
            expiryDate: Date().addingTimeInterval(900), // 15 mins
            isLimitedQuantity: true,
            remainingQuantity: Int.random(in: 3...8)
        )
    }
    
    // MARK: - The Near Miss
    func checkEvolutionProximity(pet: Pet) -> Bool {
        // If within 10% of XP needed
        let required = getRequiredXP(for: pet.stage)
        let remaining = required - pet.experience
        return remaining > 0 && remaining <= (required / 10)
    }
    
    private func getRequiredXP(for stage: PetStage) -> Int {
        // Duplicate logic from PetManager (should be shared)
        switch stage {
        case .egg: return 50
        case .baby: return 150
        case .child: return 300
        case .teen: return 500
        case .adult: return 750
        case .elder: return Int.max
        }
    }
    
    private func scheduleNotification(title: String, body: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
