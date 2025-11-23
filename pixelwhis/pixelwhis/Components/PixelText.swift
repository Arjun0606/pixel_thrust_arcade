import SwiftUI

/// Retro pixel-style text with monospace font and glow effect
struct PixelText: View {
    let text: String
    let size: CGFloat
    let color: Color
    let glow: Bool
    
    init(
        _ text: String,
        size: CGFloat = 16,
        color: Color = .white,
        glow: Bool = false
    ) {
        self.text = text
        self.size = size
        self.color = color
        self.glow = glow
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .bold, design: .monospaced))
            .tracking(size * 0.1) // Letter spacing for retro look
            .foregroundColor(color)
            .if(glow) { view in
                view.shadow(color: color.opacity(0.8), radius: 4, x: 0, y: 0)
                    .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 0)
            }
    }
}

// Helper for conditional modifiers
extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PixelText("PIXELTHRUST", size: 24, color: .electricCyan, glow: true)
        PixelText("SCORE: 12345", size: 18, color: .scoreGreen)
        PixelText("HI: 99999", size: 14, color: .starWhite)
    }
    .padding()
    .background(Color.spaceBlue)
}
