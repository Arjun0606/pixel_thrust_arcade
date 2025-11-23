import SwiftUI

struct PenaltyRecoverySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var pet: Pet
    let isPro: Bool
    
    var body: some View {
        ZStack {
            // Dark/sick themed gradient
            LinearGradient(
                colors: penaltyGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Sick pet icon
                Image(systemName: penaltyIcon)
                    .font(.system(size: 100))
                    .foregroundStyle(penaltyColor)
                    .symbolEffect(.bounce)
                
                VStack(spacing: 12) {
                    Text(penaltyTitle)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text(penaltyMessage)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Recovery options
                VStack(spacing: 16) {
                    // Option 1: Instant recovery (IAP)
                    Button(action: instantRecovery) {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "bolt.heart.fill")
                                Text(instantRecoveryTitle)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            }
                            Text(instantRecoveryPrice)
                                .font(.system(size: 14, design: .rounded))
                                .opacity(0.8)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .green.opacity(0.3), radius: 10, y: 5)
                    }
                    .buttonStyle(.plain)
                    
                    // Option 2: Wait (free but long)
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "clock.fill")
                            Text("Wait \(pet.getRecoveryTimeString(isPro: isPro))")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white.opacity(0.7))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    if isPro {
                        Text("✨ Pro members get 50% faster recovery!")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.yellow)
                    }
                }
                .padding(.horizontal, 32)
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    var penaltyGradient: [Color] {
        switch pet.penaltyState {
        case .sick: return [Color.yellow.opacity(0.3), Color.orange.opacity(0.3)]
        case .hibernating: return [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]
        case .critical: return [Color.red.opacity(0.3), Color.orange.opacity(0.3)]
        default: return [Color.gray.opacity(0.3), Color.gray.opacity(0.2)]
        }
    }
    
    var penaltyIcon: String {
        switch pet.penaltyState {
        case .sick: return "cross.case.fill"
        case .hibernating: return "moon.zzz.fill"
        case .critical: return "exclamationmark.triangle.fill"
        default: return "heart.fill"
        }
    }
    
    var penaltyColor: Color {
        switch pet.penaltyState {
        case .sick: return .orange
        case .hibernating: return .blue
        case .critical: return .red
        default: return .green
        }
    }
    
    var penaltyTitle: String {
        switch pet.penaltyState {
        case .sick: return "\(pet.name) is Sick!"
        case .hibernating: return "\(pet.name) Hibernated"
        case .critical: return "CRITICAL!"
        default: return "Recovering..."
        }
    }
    
    var penaltyMessage: String {
        switch pet.penaltyState {
        case .sick:
            return "Your pet got sick from poor care. They need time to recover or medicine to feel better."
        case .hibernating:
            return "After 12 hours of neglect, \(pet.name) went into hibernation. They've disappeared from your widget until they wake up."
        case .critical:
            return "24 hours of neglect! \(pet.name) is about to run away forever. Act fast to save them!"
        default:
            return "Your pet is recovering..."
        }
    }
    
    var instantRecoveryTitle: String {
        switch pet.penaltyState {
        case .sick: return "Use Medicine"
        case .hibernating: return "Wake Up Now"
        case .critical: return "Emergency Rescue"
        default: return "Heal Instantly"
        }
    }
    
    var instantRecoveryPrice: String {
        switch pet.penaltyState {
        case .sick: return "$0.99"
        case .hibernating: return "$1.99"
        case .critical: return "$2.99"
        default: return "$0.99"
        }
    }
    
    func instantRecovery() {
        // TODO: Integrate with StoreKit
        // For now, mock purchase
        pet.hunger = 100
        pet.happiness = 100
        pet.health = 100
        pet.energy = 100
        pet.lastInteractionDate = Date()
        dismiss()
    }
}
