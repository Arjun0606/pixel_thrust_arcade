import SwiftUI

/// Pressable pixel art button with haptic feedback
struct PixelButton: View {
    let image: String
    let isFlipped: Bool
    let tintColor: Color  // NEW: color tint
    let onPress: () -> Void
    let onRelease: () -> Void
    
    @State private var isPressed = false
    
    init(
        image: String,
        isFlipped: Bool = false,
        tintColor: Color = .white,  // Default to white
        onPress: @escaping () -> Void = {},
        onRelease: @escaping () -> Void = {}
    ) {
        self.image = image
        self.isFlipped = isFlipped
        self.tintColor = tintColor
        self.onPress = onPress
        self.onRelease = onRelease
    }
    
    var body: some View {
        Image(image)
            .resizable()
            .scaledToFit()
            .colorMultiply(tintColor)  // Apply tint!
            .scaleEffect(isPressed ? 0.85 : 1.0) // Compress when pressed
            .opacity(isPressed ? 0.8 : 1.0)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            // Haptic feedback
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            onPress()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        onRelease()
                    }
            )
    }
}

#Preview {
    VStack(spacing: 40) {
        PixelButton(image: "left_button") {
            print("Left pressed")
        } onRelease: {
            print("Left released")
        }
        .frame(width: 80, height: 80)
        
        PixelButton(image: "left_button", isFlipped: true) {
            print("Right pressed")
        } onRelease: {
            print("Right released")
        }
        .frame(width: 80, height: 80)
    }
    .padding()
    .background(Color.gray.opacity(0.3))
}
