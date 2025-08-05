import SwiftUI

extension Color {
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255,
        )
    }
}

// MARK: - Nord Theme Colors

extension Color {
    // Polar Night (Dark colors)
    static let nordNight0 = Color(hex: "2e3440") // Darkest
    static let nordNight1 = Color(hex: "3b4252")
    static let nordNight2 = Color(hex: "434c5e")
    static let nordNight3 = Color(hex: "4c566a") // Lightest dark

    // Snow Storm (Light colors)
    static let nordSnow0 = Color(hex: "d8dee9") // Darkest light
    static let nordSnow1 = Color(hex: "e5e9f0")
    static let nordSnow2 = Color(hex: "eceff4") // Lightest

    // Frost (Blue colors)
    static let nordFrost0 = Color(hex: "8fbcbb") // Cyan
    static let nordFrost1 = Color(hex: "88c0d0") // Light blue
    static let nordFrost2 = Color(hex: "81a1c1") // Blue
    static let nordFrost3 = Color(hex: "5e81ac") // Dark blue

    // Aurora (Accent colors)
    static let nordAurora0 = Color(hex: "bf616a") // Red
    static let nordAurora1 = Color(hex: "d08770") // Orange
    static let nordAurora2 = Color(hex: "ebcb8b") // Yellow
    static let nordAurora3 = Color(hex: "a3be8c") // Green
    static let nordAurora4 = Color(hex: "b48ead") // Purple
}

// MARK: - Nord Theme Semantic Colors

extension Color {
    // Semantic colors for the Pomodoro app
    static let nordBackground = Color.nordNight0
    static let nordSurface = Color.nordNight1
    static let nordBorder = Color.nordNight2
    static let nordMuted = Color.nordNight3

    static let nordPrimary = Color.nordSnow2
    static let nordSecondary = Color.nordSnow0
    static let nordTertiary = Color.nordSnow1

    static let nordAccent = Color.nordFrost2
    static let nordSuccess = Color.nordAurora3
    static let nordWarning = Color.nordAurora2
    static let nordError = Color.nordAurora0
    static let nordInfo = Color.nordFrost1
}
