import SwiftUI

enum PetEmotion: String {
    case neutral
    case happy
    case sad
    case angry
    case sick
    case sleeping
}

class AssetManager {
    static let shared = AssetManager()
    
    // In a real app, this would load from a bundle or downloaded assets.
    // For now, we map to System Images (SF Symbols) as placeholders until PixelLab assets arrive.
    
    func asset(for pet: Pet) -> String {
        if pet.isRunaway {
            return "figure.run" // Placeholder for empty/runaway
        }
        
        switch pet.stage {
        case .egg:
            return "egg" // Real pixel art dragon egg!
        case .baby:
            return "baby" // Real pixel art baby dragon!
        case .child:
            return "child" // Real pixel art child dragon!
        case .teen:
            return "hare" // Placeholder (rate limited)
        case .adult:
            return "adult" // Real pixel art adult dragon!
        case .elder:
            return "crown.fill" // Placeholder (rate limited)
        }
    }
    
    func color(for pet: Pet) -> Color {
        if pet.isRunaway { return .gray }
        
        // Dynamic color based on health/happiness
        if pet.health < 30 { return .green.opacity(0.5) } // Sickly
        if pet.happiness < 30 { return .blue } // Sad
        
        switch pet.stage {
        case .egg: return .beige
        case .baby: return .pink
        case .child: return .orange
        case .teen: return .purple
        case .adult: return .red
        case .elder: return .gold
        }
    }
}

extension Color {
    static let beige = Color(red: 0.96, green: 0.96, blue: 0.86)
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}
