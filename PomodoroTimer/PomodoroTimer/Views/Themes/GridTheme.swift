import SwiftUI

// MARK: - Grid Theme Definition

/// The GitHub contribution grid-inspired theme with discrete time visualization
struct GridTheme: ThemeDefinition {
    
    // MARK: - Theme Identity
    
    let id = "grid"
    let displayName = "Grid"
    let description = "GitHub-style contribution grid visualization"
    let icon = "grid"
    
    // MARK: - Color Properties
    
    let accentColor: ThemeColor = .triPhase(
        work: .green,
        shortBreak: .green,
        longBreak: .green
    )
    
    let backgroundColor: Color = .nordNight0.opacity(0.95)
    
    let primaryTextColor: ThemeColor = .triPhase(
        work: .nordPrimary,
        shortBreak: .nordPrimary,
        longBreak: .nordPrimary
    )
    
    let secondaryTextColor: ThemeColor = .triPhase(
        work: .nordSecondary,
        shortBreak: .nordSecondary,
        longBreak: .nordSecondary
    )
    
    let timerFont: Font = .system(size: 48, weight: .bold, design: .rounded)
    
    // MARK: - Button Theme Properties
    
    let primaryButtonColor: ThemeColor = .triPhase(
        work: .green.opacity(0.8),
        shortBreak: .green.opacity(0.8),
        longBreak: .green.opacity(0.8)
    )
    
    let secondaryButtonColor: ThemeColor = .triPhase(
        work: .nordNight2.opacity(0.7),
        shortBreak: .nordNight2.opacity(0.7),
        longBreak: .nordNight2.opacity(0.7)
    )
    
    let buttonTextColor: ThemeColor = .triPhase(
        work: .nordPrimary,
        shortBreak: .nordPrimary,
        longBreak: .nordPrimary
    )
    
    let buttonHoverColor: ThemeColor = .triPhase(
        work: .green,
        shortBreak: .green,
        longBreak: .green
    )
    
    let buttonShadowColor: Color = .black
    
    // MARK: - Window Theme Properties
    
    let windowBackgroundType: WindowBackgroundType = .solid
    let windowBackgroundColor: Color = .nordNight0.opacity(0.95)
    
    // MARK: - Theme Experience Factory
    
    func createExperience() -> AnyThemeExperience {
        return AnyThemeExperience(GridExperience())
    }
    
    // MARK: - Registration
    
    static func register() {
        ThemeRegistry.shared.register(GridTheme())
    }
}

// MARK: - Grid Theme Experience

/// Grid theme experience with contribution-style visualization and standard controls
struct GridExperience: ThemeExperience {
    
    // MARK: - Behavioral Characteristics
    
    let allowsVisualControls = true
    let preferredInteractionModel = InteractionModel.hybrid
    
    // MARK: - View Factories
    
    @ViewBuilder
    func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> some View {
        GridThemeView(rippleTrigger: rippleTrigger)
            .environmentObject(viewModel)
    }
    
    @ViewBuilder
    func makeControlsView(viewModel: TimerViewModel) -> some View {
        StandardControlsView(viewModel: viewModel)
    }
}

// MARK: - Preview Support

#Preview("Grid Theme Controls") {
    StandardControlsView(viewModel: TimerViewModel())
        .frame(width: 300, height: 150)
        .background(Color.nordNight0.opacity(0.95))
}

#Preview("Grid Experience Content") {
    @Previewable @State var rippleTrigger = false
    let experience = GridExperience()
    
    experience.makeContentView(viewModel: TimerViewModel(), rippleTrigger: .constant(false))
        .frame(width: 400, height: 380)
        .background(Color.nordNight0.opacity(0.95))
}