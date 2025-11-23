import SwiftUI

/// Animated starfield background for menus
struct AnimatedStarfield: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Deep space gradient
            LinearGradient(
                colors: [Color.deepSpace, Color.spaceBlue, Color.midBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated stars layer 1 (slow)
            GeometryReader { geometry in
                ForEach(0..<30, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.3...0.7)))
                        .frame(width: 2, height: 2)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat((index * 20) % Int(geometry.size.height)) + animationOffset * 0.2
                        )
                }
            }
            
            // Animated stars layer 2 (medium)
            GeometryReader { geometry in
                ForEach(0..<20, id: \.self) { index in
                    Circle()
                        .fill(Color.electricCyan.opacity(Double.random(in: 0.2...0.5)))
                        .frame(width: 3, height: 3)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat((index * 30) % Int(geometry.size.height)) + animationOffset * 0.5
                        )
                }
            }
            
            // Animated stars layer 3 (fast)
            GeometryReader { geometry in
                ForEach(0..<15, id: \.self) { index in
                    Circle()
                        .fill(Color.starWhite.opacity(Double.random(in: 0.5...0.9)))
                        .frame(width: 1.5, height: 1.5)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat((index * 40) % Int(geometry.size.height)) + animationOffset
                        )
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                animationOffset = UIScreen.main.bounds.height
            }
        }
    }
}
