import SwiftUI

/// Main menu screen with retro arcade aesthetic
struct MainMenuView: View {
    let onStartGame: () -> Void
    let highScore: Int
    
    @State private var titlePulse: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Animated space background
            AnimatedStarfield()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                VStack(spacing: 8) {
                    PixelText("PIXELTHRUST", size: 36, color: .electricCyan, glow: true)
                        .scaleEffect(titlePulse)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                titlePulse = 1.1
                            }
                        }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.neonMagenta)
                            .font(.system(size: 12))
                        PixelText("GRAVITY GAUNTLET", size: 14, color: .starWhite)
                        Image(systemName: "sparkles")
                            .foregroundColor(.neonMagenta)
                            .font(.system(size: 12))
                    }
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Spaceship icon
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(-45))
                    .shadow(color: .electricCyan, radius: 10)
                
                Spacer()
                
                // High score
                if highScore > 0 {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.pauseYellow)
                            PixelText("HIGH SCORE", size: 12, color: .starWhite)
                        }
                        PixelText("\(highScore)", size: 28, color: .scoreGreen, glow: true)
                    }
                    .padding(.bottom, 20)
                }
                
                // Start button
                RetroButton("▶ START GAME", icon: "play.fill", color: .electricCyan, action: onStartGame)
                
                // Instructions
                VStack(spacing: 4) {
                    PixelText("◀ ▶ THRUST", size: 10, color: .starWhite.opacity(0.6))
                    PixelText("◀+▶ BOOST ↑", size: 10, color: .starWhite.opacity(0.6))
                }
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    MainMenuView(onStartGame: {}, highScore: 12345)
}
