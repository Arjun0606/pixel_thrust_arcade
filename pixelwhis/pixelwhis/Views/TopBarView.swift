import SwiftUI

struct TopBarView: View {
    @Bindable var wallet: PlayerWallet
    @Binding var showingShop: Bool
    @Binding var showingCoinShop: Bool
    let pet: Pet?
    
    var body: some View {
        HStack(spacing: 16) {
            // Energy
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.orange)
                Text("\(wallet.energy)/\(wallet.maxEnergy)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.white.opacity(0.9))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            
            // Coins
            Button(action: { showingCoinShop = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(.yellow)
                    Text("\(wallet.coins)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Image(systemName: "cart.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.white.opacity(0.9))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
            .buttonStyle(.plain)
            
            // Gems
            Button(action: { showingShop = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "diamond.fill")
                        .foregroundStyle(.cyan)
                    Text("\(wallet.gems)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Image(systemName: "plus.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.white.opacity(0.9))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Shop Button
            Button(action: { showingShop = true }) {
                Image(systemName: "cart.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(22)
                    .shadow(color: .purple.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
