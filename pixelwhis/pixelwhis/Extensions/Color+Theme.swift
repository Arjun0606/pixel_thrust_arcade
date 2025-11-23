import SwiftUI

/// Space-themed color palette for retro arcade aesthetic
extension Color {
    // Primary colors
    static let spaceBlue = Color(hex: "0A0E27")
    static let electricCyan = Color(hex: "00F0FF")
    static let neonMagenta = Color(hex: "FF006E")
    static let starWhite = Color(hex: "B8FFE6")
    
    // Secondary colors
    static let deepSpace = Color(hex: "05070F")
    static let midBlue = Color(hex: "1A1E3E")
    static let glowCyan = Color(hex: "2DCDDF")
    static let softPurple = Color(hex: "A78BFA")
    
    // UI colors
    static let scoreGreen = Color(hex: "00FF41")
    static let warningRed = Color(hex: "FF0055")
    static let pauseYellow = Color(hex: "FFD600")
    
    // Helper initializer for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
