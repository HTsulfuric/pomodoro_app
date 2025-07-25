import SwiftUI

// MARK: - Minimal Theme Definition

/// The classic minimal theme with circular progress and clean aesthetics
struct MinimalTheme: ThemeDefinition {
    
    // MARK: - Theme Identity
    
    let id = "minimal"
    let displayName = "Minimal"
    let description = "Clean circular progress with subtle animations"
    let icon = "circle"
    
    // MARK: - Color Properties
    
    let accentColor: ThemeColor = .triPhase(
        work: .nordAccent,
        shortBreak: .nordAccent,
        longBreak: .nordAccent
    )
    
    let backgroundColor: Color = .clear
    
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
    
    let timerFont: Font = .system(size: 72, weight: .bold, design: .rounded)
    
    // MARK: - Button Theme Properties
    
    let primaryButtonColor: ThemeColor = .triPhase(
        work: .nordAccent.opacity(0.8),
        shortBreak: .nordAccent.opacity(0.8),
        longBreak: .nordAccent.opacity(0.8)
    )
    
    let secondaryButtonColor: ThemeColor = .triPhase(
        work: .nordNight3.opacity(0.6),
        shortBreak: .nordNight3.opacity(0.6),
        longBreak: .nordNight3.opacity(0.6)
    )
    
    let buttonTextColor: ThemeColor = .triPhase(
        work: .nordPrimary,
        shortBreak: .nordPrimary,
        longBreak: .nordPrimary
    )
    
    let buttonHoverColor: ThemeColor = .triPhase(
        work: .nordAccent,
        shortBreak: .nordAccent,
        longBreak: .nordAccent
    )
    
    let buttonShadowColor: Color = .black
    
    // MARK: - Window Theme Properties
    
    let windowBackgroundType: WindowBackgroundType = .blur
    let windowBackgroundColor: Color = .clear
    
    // MARK: - Theme Experience Factory
    
    func createExperience() -> AnyThemeExperience {
        return AnyThemeExperience(MinimalExperience())
    }
    
    // MARK: - Registration
    
    static func register() {
        ThemeRegistry.shared.register(MinimalTheme())
    }
}

// MARK: - Minimal Theme Experience

/// Minimal theme experience with circular progress and standard controls
struct MinimalExperience: ThemeExperience {
    
    // MARK: - Behavioral Characteristics
    
    let allowsVisualControls = true
    let preferredInteractionModel = InteractionModel.graphical
    
    // MARK: - View Factories
    
    @ViewBuilder
    func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> some View {
        MinimalThemeView(rippleTrigger: rippleTrigger)
            .environmentObject(viewModel)
    }
    
    @ViewBuilder
    func makeControlsView(viewModel: TimerViewModel) -> some View {
        StandardControlsView(viewModel: viewModel)
    }
}

// MARK: - Shared Controls View

/// Standard control layout used by graphical themes (Minimal and Grid)
struct StandardControlsView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Play/Pause button (primary) with space key feedback
                Button(action: {
                    toggleTimer()
                }) {
                    Image(systemName: viewModel.pomodoroState.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(viewModel.currentTheme.buttonTextColor.color(for: viewModel.pomodoroState.currentPhase))
                        .frame(width: 50, height: 50)
                        .background(viewModel.currentTheme.primaryButtonColor.color(for: viewModel.pomodoroState.currentPhase))
                        .clipShape(Circle())
                }
                .buttonStyle(CircleHoverButtonStyle(theme: viewModel.currentTheme))
                
                // Skip button
                Button(action: {
                    viewModel.skipPhase()
                }) {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(viewModel.currentTheme.buttonTextColor.color(for: viewModel.pomodoroState.currentPhase))
                        .frame(width: 44, height: 44)
                        .background(viewModel.currentTheme.secondaryButtonColor.color(for: viewModel.pomodoroState.currentPhase))
                        .clipShape(Circle())
                }
                .buttonStyle(CircleHoverButtonStyle(theme: viewModel.currentTheme))
            }
            
            HStack(spacing: 20) {
                // Reset button
                Button(action: {
                    viewModel.resetTimer()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(viewModel.currentTheme.buttonTextColor.color(for: viewModel.pomodoroState.currentPhase))
                        .frame(width: 44, height: 44)
                        .background(viewModel.currentTheme.secondaryButtonColor.color(for: viewModel.pomodoroState.currentPhase))
                        .clipShape(Circle())
                }
                .buttonStyle(CircleHoverButtonStyle(theme: viewModel.currentTheme))
                
                // Test Sound button
                Button(action: {
                    print("🔊 Testing sound manually...")
                    SoundManager.shared.playPhaseChangeSound(for: .work)
                }) {
                    Image(systemName: "speaker.2.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(viewModel.currentTheme.buttonTextColor.color(for: viewModel.pomodoroState.currentPhase))
                        .frame(width: 44, height: 44)
                        .background(viewModel.currentTheme.secondaryButtonColor.color(for: viewModel.pomodoroState.currentPhase))
                        .clipShape(Circle())
                }
                .buttonStyle(CircleHoverButtonStyle(theme: viewModel.currentTheme))
            }
        }
    }
    
    /// Toggle timer without visual feedback (for button clicks)
    private func toggleTimer() {
        if viewModel.pomodoroState.isRunning {
            viewModel.pauseTimer()
        } else {
            viewModel.startTimer()
        }
    }
}

// MARK: - Preview Support

#Preview("Minimal Theme Controls") {
    StandardControlsView(viewModel: TimerViewModel())
        .frame(width: 300, height: 150)
        .background(Color.black.opacity(0.8))
}

#Preview("Minimal Experience Content") {
    @Previewable @State var rippleTrigger = false
    let experience = MinimalExperience()
    
    experience.makeContentView(viewModel: TimerViewModel(), rippleTrigger: .constant(false))
        .frame(width: 300, height: 400)
        .background(Color.black.opacity(0.8))
}