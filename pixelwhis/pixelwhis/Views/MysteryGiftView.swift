import SwiftUI

struct MysteryGiftView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var wallet: PlayerWallet
    
    @State private var isOpening = false
    @State private var reward: (String, Int)?
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 30) {
                if let reward = reward {
                    // Reward Reveal
                    VStack(spacing: 20) {
                        Text("You Found!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Image(systemName: icon(for: reward.0))
                            .font(.system(size: 80))
                            .foregroundStyle(color(for: reward.0))
                            .symbolEffect(.bounce)
                        
                        Text("+\(reward.1) \(reward.0)")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundStyle(color(for: reward.0))
                        
                        Button("Awesome!") {
                            dismiss()
                        }
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(20)
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // Mystery Box
                    VStack(spacing: 20) {
                        Text("Mystery Gift!")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .orange, radius: 10)
                        
                        Button(action: openGift) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 120))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.red, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .yellow.opacity(0.5), radius: 20)
                                .scaleEffect(scale)
                                .rotationEffect(.degrees(rotation))
                        }
                        .buttonStyle(.plain)
                        
                        Text("Tap to Open")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .opacity(isOpening ? 0 : 1)
                    }
                }
            }
        }
    }
    
    func openGift() {
        guard !isOpening else { return }
        isOpening = true
        
        // Animation sequence
        withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
            scale = 1.2
        }
        
        withAnimation(.linear(duration: 0.1).repeatCount(5, autoreverses: true)) {
            rotation = 10
        }
        
        // Haptic & Sound
        SoundManager.shared.playNotificationHaptic(.success)
        SoundManager.shared.playSFX("success")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let result = PsychologyManager.shared.openMysteryGift()
            
            // Apply reward
            if result.0 == "Coins" {
                wallet.coins += result.1
            } else if result.0 == "Energy" {
                wallet.energy = min(wallet.maxEnergy, wallet.energy + result.1)
            } else if result.0 == "Gem" {
                wallet.gems += result.1
            }
            
            withAnimation(.spring()) {
                reward = result
                scale = 1.0
                rotation = 0
            }
        }
    }
    
    func icon(for type: String) -> String {
        switch type {
        case "Coins": return "circle.fill"
        case "Energy": return "bolt.fill"
        case "Gem": return "diamond.fill"
        default: return "star.fill"
    }
    }
    
    func color(for type: String) -> Color {
        switch type {
        case "Coins": return .yellow
        case "Energy": return .orange
        case "Gem": return .cyan
        default: return .white
        }
    }
}
