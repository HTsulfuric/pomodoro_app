import SwiftUI
import AppKit

/// Represents a theme color that can vary by Pomodoro phase
enum ThemeColor: Equatable {
    case triPhase(work: Color, shortBreak: Color, longBreak: Color)
    
    /// Returns the appropriate color for the given Pomodoro phase
    func color(for phase: PomodoroPhase) -> Color {
        switch self {
        case .triPhase(let work, let shortBreak, let longBreak):
            switch phase {
            case .work:
                return work
            case .shortBreak:
                return shortBreak
            case .longBreak:
                return longBreak
            }
        }
    }
}

/// Window background type options for themes
enum WindowBackgroundType {
    case blur
    case solid
    case gradient
}

/// Represents different visual themes for the Pomodoro timer
struct Theme: Identifiable, Equatable {
    let id: String
    let displayName: String
    let description: String
    let icon: String
    
    // Color properties using ThemeColor
    let accentColor: ThemeColor
    let backgroundColor: Color
    let primaryTextColor: ThemeColor
    let secondaryTextColor: ThemeColor
    let timerFont: Font
    
    // Button theme properties
    let primaryButtonColor: ThemeColor
    let secondaryButtonColor: ThemeColor
    let buttonTextColor: ThemeColor
    let buttonHoverColor: ThemeColor
    let buttonShadowColor: Color
    
    // Window theme properties
    let windowBackgroundType: WindowBackgroundType
    let windowBackgroundColor: Color
    let preferredWindowSize: CGSize
    
    // Static initializer for consistent window size calculation
    private static var fullScreenSize: CGSize {
        if let screen = NSScreen.main {
            return screen.frame.size
        }
        return CGSize(width: 1920, height: 1080) // Fallback
    }
    
    // MARK: - Static Theme Instances
    
    static let minimal = Theme(
        id: "minimal",
        displayName: "Minimal",
        description: "Clean circular progress with subtle animations",
        icon: "circle",
        accentColor: .triPhase(work: .nordAccent, shortBreak: .nordAccent, longBreak: .nordAccent),
        backgroundColor: .clear,
        primaryTextColor: .triPhase(work: .nordPrimary, shortBreak: .nordPrimary, longBreak: .nordPrimary),
        secondaryTextColor: .triPhase(work: .nordSecondary, shortBreak: .nordSecondary, longBreak: .nordSecondary),
        timerFont: .system(size: 72, weight: .bold, design: .rounded),
        primaryButtonColor: .triPhase(work: .nordAccent.opacity(0.8), shortBreak: .nordAccent.opacity(0.8), longBreak: .nordAccent.opacity(0.8)),
        secondaryButtonColor: .triPhase(work: .nordNight3.opacity(0.6), shortBreak: .nordNight3.opacity(0.6), longBreak: .nordNight3.opacity(0.6)),
        buttonTextColor: .triPhase(work: .nordPrimary, shortBreak: .nordPrimary, longBreak: .nordPrimary),
        buttonHoverColor: .triPhase(work: .nordAccent, shortBreak: .nordAccent, longBreak: .nordAccent),
        buttonShadowColor: .black,
        windowBackgroundType: .blur,
        windowBackgroundColor: .clear,
        preferredWindowSize: fullScreenSize
    )
    
    static let grid = Theme(
        id: "grid",
        displayName: "Grid",
        description: "GitHub-style contribution grid visualization",
        icon: "grid",
        accentColor: .triPhase(work: .green, shortBreak: .green, longBreak: .green),
        backgroundColor: .nordNight0.opacity(0.95),
        primaryTextColor: .triPhase(work: .nordPrimary, shortBreak: .nordPrimary, longBreak: .nordPrimary),
        secondaryTextColor: .triPhase(work: .nordSecondary, shortBreak: .nordSecondary, longBreak: .nordSecondary),
        timerFont: .system(size: 48, weight: .bold, design: .rounded),
        primaryButtonColor: .triPhase(work: .green.opacity(0.8), shortBreak: .green.opacity(0.8), longBreak: .green.opacity(0.8)),
        secondaryButtonColor: .triPhase(work: .nordNight2.opacity(0.7), shortBreak: .nordNight2.opacity(0.7), longBreak: .nordNight2.opacity(0.7)),
        buttonTextColor: .triPhase(work: .nordPrimary, shortBreak: .nordPrimary, longBreak: .nordPrimary),
        buttonHoverColor: .triPhase(work: .green, shortBreak: .green, longBreak: .green),
        buttonShadowColor: .black,
        windowBackgroundType: .solid,
        windowBackgroundColor: .nordNight0.opacity(0.95),
        preferredWindowSize: fullScreenSize
    )
    
    static let terminal = Theme(
        id: "terminal",
        displayName: "Terminal",
        description: "Retro green-on-black hacker aesthetic",
        icon: "terminal",
        accentColor: .triPhase(
            work: Color(red: 0, green: 1, blue: 0),
            shortBreak: Color(red: 1, green: 0.75, blue: 0),
            longBreak: Color(red: 0.5, green: 0.5, blue: 1)
        ),
        backgroundColor: .black,
        primaryTextColor: .triPhase(
            work: Color(red: 0, green: 1, blue: 0),
            shortBreak: Color(red: 1, green: 0.75, blue: 0),
            longBreak: Color(red: 0.5, green: 0.5, blue: 1)
        ),
        secondaryTextColor: .triPhase(
            work: Color(red: 0, green: 0.8, blue: 0),
            shortBreak: Color(red: 1, green: 0.6, blue: 0),
            longBreak: Color(red: 0.4, green: 0.4, blue: 0.8)
        ),
        timerFont: .system(size: 56, weight: .bold, design: .monospaced),
        primaryButtonColor: .triPhase(
            work: Color(red: 0, green: 0.8, blue: 0).opacity(0.8),
            shortBreak: Color(red: 1, green: 0.6, blue: 0).opacity(0.8),
            longBreak: Color(red: 0.4, green: 0.4, blue: 0.8).opacity(0.8)
        ),
        secondaryButtonColor: .triPhase(
            work: Color(red: 0, green: 0.4, blue: 0).opacity(0.6),
            shortBreak: Color(red: 0.6, green: 0.3, blue: 0).opacity(0.6),
            longBreak: Color(red: 0.2, green: 0.2, blue: 0.4).opacity(0.6)
        ),
        buttonTextColor: .triPhase(
            work: Color(red: 0, green: 1, blue: 0),
            shortBreak: Color(red: 1, green: 0.75, blue: 0),
            longBreak: Color(red: 0.5, green: 0.5, blue: 1)
        ),
        buttonHoverColor: .triPhase(
            work: Color(red: 0, green: 1, blue: 0),
            shortBreak: Color(red: 1, green: 0.75, blue: 0),
            longBreak: Color(red: 0.5, green: 0.5, blue: 1)
        ),
        buttonShadowColor: Color(red: 0, green: 0.5, blue: 0),
        windowBackgroundType: .solid,
        windowBackgroundColor: .black,
        preferredWindowSize: fullScreenSize
    )
    
    // MARK: - Theme Collection
    
    static let allCases: [Theme] = [minimal, grid, terminal]
}