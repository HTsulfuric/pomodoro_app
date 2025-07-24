import SwiftUI
import AppKit

/// Represents different visual themes for the Pomodoro timer
enum Theme: String, CaseIterable, Identifiable {
    case minimal
    case grid
    case terminal
    
    var id: String { self.rawValue }
    
    /// Display name for the theme selector
    var displayName: String {
        switch self {
        case .minimal:
            return "Minimal"
        case .grid:
            return "Grid"
        case .terminal:
            return "Terminal"
        }
    }
    
    /// Description of the theme's aesthetic
    var description: String {
        switch self {
        case .minimal:
            return "Clean circular progress with subtle animations"
        case .grid:
            return "GitHub-style contribution grid visualization"
        case .terminal:
            return "Retro green-on-black hacker aesthetic"
        }
    }
    
    /// Primary accent color for the theme
    var accentColor: Color {
        switch self {
        case .minimal:
            return .nordAccent
        case .grid:
            return .green
        case .terminal:
            return Color(red: 0, green: 1, blue: 0) // Terminal green
        }
    }
    
    /// Background color for the theme
    var backgroundColor: Color {
        switch self {
        case .minimal:
            return .clear // Uses existing blur background
        case .grid:
            return .nordNight0.opacity(0.95)
        case .terminal:
            return .black
        }
    }
    
    /// Primary text color for the theme
    var primaryTextColor: Color {
        switch self {
        case .minimal:
            return .nordPrimary
        case .grid:
            return .nordPrimary
        case .terminal:
            return Color(red: 0, green: 1, blue: 0) // Terminal green
        }
    }
    
    /// Secondary text color for the theme
    var secondaryTextColor: Color {
        switch self {
        case .minimal:
            return .nordSecondary
        case .grid:
            return .nordSecondary
        case .terminal:
            return Color(red: 0, green: 0.8, blue: 0) // Dimmer terminal green
        }
    }
    
    /// Font to use for the main timer display
    var timerFont: Font {
        switch self {
        case .minimal:
            return .system(size: 72, weight: .bold, design: .rounded)
        case .grid:
            return .system(size: 48, weight: .bold, design: .rounded)
        case .terminal:
            return .system(size: 56, weight: .bold, design: .monospaced)
        }
    }
    
    /// Icon to display in theme selector
    var icon: String {
        switch self {
        case .minimal:
            return "circle"
        case .grid:
            return "grid"
        case .terminal:
            return "terminal"
        }
    }
    
    /// Full screen dimensions for all themes (simplified approach)
    var preferredWindowSize: CGSize {
        if let screen = NSScreen.main {
            return screen.frame.size
        }
        return CGSize(width: 1920, height: 1080) // Fallback to common large size
    }
}