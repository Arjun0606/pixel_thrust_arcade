import SwiftUI
import Combine

struct FlashSaleView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var wallet: PlayerWallet
    let deal: DailyDeal
    
    @State private var timeRemaining: TimeInterval = 900 // 15 minutes
    @State private var quantityRemaining: Int
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(wallet: PlayerWallet, deal: DailyDeal) {
        self.wallet = wallet
        self.deal = deal
        _quantityRemaining = State(initialValue: deal.remainingQuantity ?? 0)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            // Confetti/Rays background effect
            RaysView()
                .opacity(0.3)
                .rotationEffect(.degrees(Double(timeRemaining) * 10))
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("FLASH SALE")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .red, radius: 10)
                    
                    HStack {
                        Image(systemName: "timer")
                            .foregroundStyle(.yellow)
                        Text(timeString(from: timeRemaining))
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundStyle(.yellow)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.red.opacity(0.8))
                    .cornerRadius(12)
                }
                
                // Product Card
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundStyle(.purple)
                        .padding()
                        .background(Circle().fill(.white.opacity(0.2)))
                    
                    Text("Rare Trait Pack")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    
                    Text("Unlock exclusive cosmic traits for your next evolution!")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        Text("$4.99")
                            .strikethrough()
                            .foregroundStyle(.gray)
                        
                        Text("$1.99")
                            .font(.title.bold())
                            .foregroundStyle(.green)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(colors: [.purple.opacity(0.5), .blue.opacity(0.5)], startPoint: .top, endPoint: .bottom))
                        .stroke(.white.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Scarcity Indicator
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("Only \(quantityRemaining) left at this price!")
                        .font(.headline)
                        .foregroundStyle(.orange)
                }
                
                Spacer()
                
                // CTA
                Button(action: purchase) {
                    Text("Claim Offer")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                        .shadow(color: .green.opacity(0.5), radius: 10)
                }
                .padding(.horizontal, 32)
                
                Button("No thanks, I hate saving money") {
                    dismiss()
                }
                .font(.footnote)
                .foregroundStyle(.gray)
                .padding(.bottom)
            }
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                dismiss()
            }
            
            // Fake social proof: randomly decrease quantity
            if quantityRemaining > 1 && Int.random(in: 1...100) < 5 {
                withAnimation {
                    quantityRemaining -= 1
                }
            }
        }
    }
    
    func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func purchase() {
        // Mock purchase
        wallet.gems += 50 // Give value
        SoundManager.shared.playSFX("coin")
        SoundManager.shared.playNotificationHaptic(.success)
        dismiss()
    }
}

struct RaysView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                for i in 0..<12 {
                    let angle = Angle.degrees(Double(i) * 30)
                    path.move(to: center)
                    path.addArc(center: center, radius: 1000, startAngle: angle, endAngle: angle + .degrees(15), clockwise: false)
                    path.closeSubpath()
                }
            }
            .fill(Color.white)
        }
    }
}
