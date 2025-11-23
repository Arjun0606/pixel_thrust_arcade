import SwiftUI

/// Pixel art style border modifier for game viewport and cards
struct PixelBorder: ViewModifier {
    let color: Color
    let width: CGFloat
    let gradient: Bool
    
    init(color: Color = .electricCyan, width: CGFloat = 4, gradient: Bool = true) {
        self.color = color
        self.width = width
        self.gradient = gradient
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .strokeBorder(
                        gradient ?
                            AnyShapeStyle(
                                LinearGradient(
                                    colors: [color, color.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            ) :
                            AnyShapeStyle(color),
                        lineWidth: width
                    )
            )
    }
}

extension View {
    func pixelBorder(color: Color = .electricCyan, width: CGFloat = 4, gradient: Bool = true) -> some View {
        modifier(PixelBorder(color: color, width: width, gradient: gradient))
    }
}

#Preview {
    VStack(spacing: 30) {
        Rectangle()
            .fill(Color.black)
            .frame(width: 200, height: 150)
            .pixelBorder(color: .electricCyan)
        
        Rectangle()
            .fill(Color.deepSpace)
            .frame(width: 200, height: 150)
            .pixelBorder(color: .neonMagenta, gradient: false)
    }
    .padding()
    .background(Color.spaceBlue)
}
