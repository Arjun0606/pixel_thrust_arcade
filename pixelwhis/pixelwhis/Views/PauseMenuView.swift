import SwiftUI

/// Pause menu overlay
struct PauseMenuView: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let score: Int
    
    var body: some View {
        ZStack {
            // Semi-transparent overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Title
                PixelText("PAUSED", size: 32, color: .pauseYellow, glow: true)
                    .padding(.top, 80)
                
                // Current score
                VStack(spacing: 8) {
                    PixelText("CURRENT SCORE", size: 12, color: .starWhite)
                    PixelText("\(score)", size: 36, color: .scoreGreen, glow: true)
                }
                .padding(.vertical, 20)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    RetroButton("▶ RESUME", icon: "play.fill", color: .scoreGreen, action: onResume)
                    
                    RetroButton("⟳ RESTART", icon: "arrow.clockwise", color: .electricCyan, action: onRestart)
                }
                
                Spacer()
            }
            .frame(maxWidth: 320)
        }
    }
}

#Preview {
    PauseMenuView(
        onResume: {},
        onRestart: {},
        score: 1234
    )
}
