import SwiftUI

struct CoinShopView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var wallet: PlayerWallet
    let pet: Pet?
    
    @State private var purchaseSuccess = false
    @State private var selectedItem: CoinShopItem?
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.yellow)
                                Text("\(wallet.coins) Coins")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                            }
                            Text("Spend your earned coins here!")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top)
                        
                        // Coin Shop Items
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(CoinShopItem.allCases, id: \.self) { item in
                                CoinItemCard(
                                    item: item,
                                    wallet: wallet,
                                    pet: pet,
                                    onPurchase: {
                                        selectedItem = item
                                        withAnimation {
                                            purchaseSuccess = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            withAnimation {
                                                purchaseSuccess = false
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                if purchaseSuccess {
                    VStack {
                        Spacer()
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Purchased \(selectedItem?.name ?? "")!")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .padding()
                        .background(.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .padding(.bottom, 40)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .navigationTitle("Coin Shop")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct CoinItemCard: View {
    let item: CoinShopItem
    @Bindable var wallet: PlayerWallet
    let pet: Pet?
    let onPurchase: () -> Void
    
    var canAfford: Bool {
        wallet.canAfford(coins: item.coinCost)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: item.icon)
                    .font(.title2)
                    .foregroundStyle(iconColor)
                Spacer()
            }
            
            Text(item.name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            Text(item.description)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "circle.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                Text("\(item.coinCost)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            
            Button(action: purchase) {
                Text(canAfford ? "Buy" : "Not Enough")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(canAfford ? Color.orange : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!canAfford)
            .buttonStyle(.plain)
        }
        .padding()
        .background(.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        .opacity(canAfford ? 1.0 : 0.6)
    }
    
    var iconColor: Color {
        switch item.color {
        case "orange": return .orange
        case "pink": return .pink
        case "purple": return .purple
        case "cyan": return .cyan
        default: return .blue
        }
    }
    
    func purchase() {
        if wallet.purchaseCoinItem(item, for: pet) {
            onPurchase()
        }
    }
}
