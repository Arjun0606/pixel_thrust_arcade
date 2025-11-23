import SwiftUI

/// CRT scanline overlay effect for retro arcade feel
struct ScanlineOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach(0..<Int(geometry.size.height / 4), id: \.self) { _ in
                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 2)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 2)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

extension View {
    func scanlineEffect() -> some View {
        overlay(ScanlineOverlay())
    }
}
