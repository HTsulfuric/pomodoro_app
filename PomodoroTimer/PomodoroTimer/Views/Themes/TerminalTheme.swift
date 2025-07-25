import SwiftUI

// MARK: - Terminal Theme Definition

/// The retro terminal theme with command-line aesthetic and invisible controls
struct TerminalTheme: ThemeDefinition {
    
    // MARK: - Theme Identity
    
    let id = "terminal"
    let displayName = "Terminal"
    let description = "Retro green-on-black hacker aesthetic"
    let icon = "terminal"
    
    // MARK: - Color Properties
    
    let accentColor: ThemeColor = .triPhase(
        work: Color(red: 0, green: 1, blue: 0),
        shortBreak: Color(red: 1, green: 0.75, blue: 0),
        longBreak: Color(red: 0.5, green: 0.5, blue: 1)
    )
    
    let backgroundColor: Color = .black
    
    let primaryTextColor: ThemeColor = .triPhase(
        work: Color(red: 0, green: 1, blue: 0),
        shortBreak: Color(red: 1, green: 0.75, blue: 0),
        longBreak: Color(red: 0.5, green: 0.5, blue: 1)
    )
    
    let secondaryTextColor: ThemeColor = .triPhase(
        work: Color(red: 0, green: 0.8, blue: 0),
        shortBreak: Color(red: 1, green: 0.6, blue: 0),
        longBreak: Color(red: 0.4, green: 0.4, blue: 0.8)
    )
    
    let timerFont: Font = .system(size: 56, weight: .bold, design: .monospaced)
    
    // MARK: - Button Theme Properties
    
    let primaryButtonColor: ThemeColor = .triPhase(
        work: Color(red: 0, green: 0.8, blue: 0).opacity(0.8),
        shortBreak: Color(red: 1, green: 0.6, blue: 0).opacity(0.8),
        longBreak: Color(red: 0.4, green: 0.4, blue: 0.8).opacity(0.8)
    )
    
    let secondaryButtonColor: ThemeColor = .triPhase(
        work: Color(red: 0, green: 0.4, blue: 0).opacity(0.6),
        shortBreak: Color(red: 0.6, green: 0.3, blue: 0).opacity(0.6),
        longBreak: Color(red: 0.2, green: 0.2, blue: 0.4).opacity(0.6)
    )
    
    let buttonTextColor: ThemeColor = .triPhase(
        work: Color(red: 0, green: 1, blue: 0),
        shortBreak: Color(red: 1, green: 0.75, blue: 0),
        longBreak: Color(red: 0.5, green: 0.5, blue: 1)
    )
    
    let buttonHoverColor: ThemeColor = .triPhase(
        work: Color(red: 0, green: 1, blue: 0),
        shortBreak: Color(red: 1, green: 0.75, blue: 0),
        longBreak: Color(red: 0.5, green: 0.5, blue: 1)
    )
    
    let buttonShadowColor: Color = Color(red: 0, green: 0.5, blue: 0)
    
    // MARK: - Window Theme Properties
    
    let windowBackgroundType: WindowBackgroundType = .solid
    let windowBackgroundColor: Color = .black
    
    // MARK: - Theme Experience Factory
    
    func createExperience() -> AnyThemeExperience {
        return AnyThemeExperience(TerminalExperience())
    }
    
    // MARK: - Registration
    
    static func register() {
        ThemeRegistry.shared.register(TerminalTheme())
    }
}

// MARK: - Terminal Theme Experience

/// Terminal theme experience with command-line aesthetic and invisible controls
struct TerminalExperience: ThemeExperience {
    
    // MARK: - Behavioral Characteristics
    
    let allowsVisualControls = false  // This is the key architectural difference
    let preferredInteractionModel = InteractionModel.commandLine
    let requiresKeyboardFocus = true
    
    // MARK: - View Factories
    
    @ViewBuilder
    func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> some View {
        TerminalThemeView(rippleTrigger: rippleTrigger)
            .environmentObject(viewModel)
    }
    
    @ViewBuilder
    func makeControlsView(viewModel: TimerViewModel) -> some View {
        EmptyView()  // No visible controls - purely keyboard driven
    }
    
    // MARK: - Custom Keyboard Behaviors
    
    func customKeyboardBehavior(for keyCode: UInt16) -> KeyboardBehavior? {
        switch keyCode {
        case 46: // M key - could toggle minimal mode overlay within terminal
            return .enhanced(
                action: {
                    // Future enhancement: show/hide minimal stats overlay
                    print("🖥️ Terminal: Enhanced info mode")
                },
                visualFeedback: "INFO_MODE"
            )
        case 18: // 1 key - could show session shortcuts
            return .enhanced(
                action: {
                    print("🖥️ Terminal: Session shortcuts displayed")
                },
                visualFeedback: "SHORTCUTS"
            )
        default:
            return nil // Use default behavior
        }
    }
}

// MARK: - Preview Support

#Preview("Terminal Experience Content") {
    @Previewable @State var rippleTrigger = false
    let experience = TerminalExperience()
    
    experience.makeContentView(viewModel: TimerViewModel(), rippleTrigger: .constant(false))
        .frame(width: 800, height: 600)
        .background(Color.black)
}