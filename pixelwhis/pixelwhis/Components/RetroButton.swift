import SwiftUI

/// Retro arcade-style button with pixel borders and press animation
struct RetroButton: View {
    let text: String
    let icon: String?
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        _ text: String,
        icon: String? = nil,
        color: Color = .electricCyan,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(text)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .tracking(1)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .strokeBorder(Color.white, lineWidth: 2)
            )
            .shadow(color: color.opacity(0.5), radius: 8, x: 0, y: 4)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    VStack(spacing: 30) {
        RetroButton("START GAME", icon: "play.fill", color: .electricCyan) {
            print("Start")
        }
        
        RetroButton("RETRY", icon: "arrow.clockwise", color: .scoreGreen) {
            print("Retry")
        }
        
        RetroButton("MENU", icon: "house.fill", color: .neonMagenta) {
            print("Menu")
        }
    }
    .padding()
    .background(Color.spaceBlue)
}
