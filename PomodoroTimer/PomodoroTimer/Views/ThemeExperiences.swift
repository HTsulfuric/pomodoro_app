import SwiftUI

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
                        .foregroundColor(viewModel.currentTheme.buttonTextColor)
                        .frame(width: 50, height: 50)
                        .background(viewModel.currentTheme.primaryButtonColor)
                        .clipShape(Circle())
                }
                .buttonStyle(CircleHoverButtonStyle(theme: viewModel.currentTheme))
                
                // Skip button
                Button(action: {
                    viewModel.skipPhase()
                }) {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(viewModel.currentTheme.buttonTextColor)
                        .frame(width: 44, height: 44)
                        .background(viewModel.currentTheme.secondaryButtonColor)
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
                        .foregroundColor(viewModel.currentTheme.buttonTextColor)
                        .frame(width: 44, height: 44)
                        .background(viewModel.currentTheme.secondaryButtonColor)
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
                        .foregroundColor(viewModel.currentTheme.buttonTextColor)
                        .frame(width: 44, height: 44)
                        .background(viewModel.currentTheme.secondaryButtonColor)
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

// MARK: - Concrete Theme Experiences

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

#Preview("Standard Controls") {
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

#Preview("Terminal Experience Content") {
    @Previewable @State var rippleTrigger = false
    let experience = TerminalExperience()
    
    experience.makeContentView(viewModel: TimerViewModel(), rippleTrigger: .constant(false))
        .frame(width: 300, height: 400)
        .background(Color.black)
}