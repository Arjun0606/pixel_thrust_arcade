import SwiftUI

struct EnergyDepletedSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var wallet: PlayerWallet
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.red.opacity(0.2), Color.orange.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "bolt.slash.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)
                    .symbolEffect(.bounce)
                
                Text("Out of Energy!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("You need \(wallet.maxEnergy - wallet.energy) more energy to continue")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    // Option 1: Buy energy
                    Button(action: {
                        // Purchase energy refill
                        dismiss()
                    }) {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("Refill Energy Now")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            }
                            Text("$0.99 for 50 energy")
                                .font(.system(size: 14, design: .rounded))
                                .opacity(0.8)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    
                    // Option 2: Wait
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "clock.fill")
                            Text("Wait \(timeUntilFull())")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white.opacity(0.7))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .presentationDetents([.medium])
    }
    
    func timeUntilFull() -> String {
        let energyNeeded = wallet.maxEnergy - wallet.energy
        let minutesNeeded = energyNeeded * 5
        
        if minutesNeeded < 60 {
            return "\(minutesNeeded)m"
        } else {
            let hours = minutesNeeded / 60
            let mins = minutesNeeded % 60
            return "\(hours)h \(mins)m"
        }
    }
}
