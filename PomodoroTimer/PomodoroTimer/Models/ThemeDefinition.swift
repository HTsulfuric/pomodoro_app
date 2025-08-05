import AppKit
import SwiftUI

/// Represents a theme color that can vary by Pomodoro phase
enum ThemeColor: Equatable {
    case triPhase(work: Color, shortBreak: Color, longBreak: Color)

    /// Returns the appropriate color for the given Pomodoro phase
    func color(for phase: PomodoroPhase) -> Color {
        switch self {
        case let .triPhase(work, shortBreak, longBreak):
            switch phase {
            case .work:
                work
            case .shortBreak:
                shortBreak
            case .longBreak:
                longBreak
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

/// Protocol that all themes must conform to for dynamic registration
protocol ThemeDefinition: Identifiable, Equatable {
    // MARK: - Theme Identity

    var id: String { get }
    var displayName: String { get }
    var description: String { get }
    var icon: String { get }

    // MARK: - Color Properties

    var accentColor: ThemeColor { get }
    var backgroundColor: Color { get }
    var primaryTextColor: ThemeColor { get }
    var secondaryTextColor: ThemeColor { get }
    var timerFont: Font { get }

    // MARK: - Button Theme Properties

    var primaryButtonColor: ThemeColor { get }
    var secondaryButtonColor: ThemeColor { get }
    var buttonTextColor: ThemeColor { get }
    var buttonHoverColor: ThemeColor { get }
    var buttonShadowColor: Color { get }

    // MARK: - Window Theme Properties

    var windowBackgroundType: WindowBackgroundType { get }
    var windowBackgroundColor: Color { get }
    var preferredWindowSize: CGSize { get }

    // MARK: - Theme Experience Factory

    /// Creates the theme experience for this theme
    func createExperience() -> AnyThemeExperience

    // MARK: - Registration

    /// Called during app startup to register this theme with the registry
    static func register()
}

// MARK: - Default Implementations

extension ThemeDefinition {
    /// Default equatable implementation based on ID
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    /// Static helper for calculating full screen size
    static var fullScreenSize: CGSize {
        if let screen = NSScreen.main {
            return screen.frame.size
        }
        return CGSize(width: 1920, height: 1080) // Fallback
    }

    /// Default preferred window size is full screen
    var preferredWindowSize: CGSize {
        Self.fullScreenSize
    }
}

// MARK: - Type-Erased Theme Wrapper

/// Type-erased wrapper for ThemeDefinition to enable uniform handling
struct AnyTheme: ThemeDefinition {
    // MARK: - Private Storage

    private let _theme: any ThemeDefinition

    // MARK: - Initialization

    init(_ theme: some ThemeDefinition) {
        _theme = theme
    }

    // MARK: - ThemeDefinition Implementation

    var id: String { _theme.id }
    var displayName: String { _theme.displayName }
    var description: String { _theme.description }
    var icon: String { _theme.icon }

    var accentColor: ThemeColor { _theme.accentColor }
    var backgroundColor: Color { _theme.backgroundColor }
    var primaryTextColor: ThemeColor { _theme.primaryTextColor }
    var secondaryTextColor: ThemeColor { _theme.secondaryTextColor }
    var timerFont: Font { _theme.timerFont }

    var primaryButtonColor: ThemeColor { _theme.primaryButtonColor }
    var secondaryButtonColor: ThemeColor { _theme.secondaryButtonColor }
    var buttonTextColor: ThemeColor { _theme.buttonTextColor }
    var buttonHoverColor: ThemeColor { _theme.buttonHoverColor }
    var buttonShadowColor: Color { _theme.buttonShadowColor }

    var windowBackgroundType: WindowBackgroundType { _theme.windowBackgroundType }
    var windowBackgroundColor: Color { _theme.windowBackgroundColor }
    var preferredWindowSize: CGSize { _theme.preferredWindowSize }

    func createExperience() -> AnyThemeExperience {
        _theme.createExperience()
    }

    static func register() {
        // Type-erased wrapper doesn't register itself
        fatalError("AnyTheme should not be registered directly")
    }
}
