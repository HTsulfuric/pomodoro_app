import SwiftUI
import AppKit

// MARK: - Aura Theme Definition

/// The revolutionary Aura theme with particle physics and glassmorphism
/// Represents focus as a living, organic entity through generative visuals
struct AuraTheme: ThemeDefinition {
    
    // MARK: - Theme Identity
    
    let id = "aura"
    let displayName = "Aura"
    let description = "A living particle system that visualizes your focus state"
    let icon = "sparkles"
    
    // MARK: - Color Properties
    
    let accentColor: ThemeColor = .triPhase(
        work: Color(red: 129/255, green: 199/255, blue: 244/255),        // Light focus blue
        shortBreak: Color(red: 167/255, green: 245/255, blue: 229/255),  // Soft mint
        longBreak: Color(red: 248/255, green: 221/255, blue: 170/255)    // Soft gold
    )
    
    let backgroundColor: Color = Color(red: 0, green: 0, blue: 0, opacity: 0.15)
    
    let primaryTextColor: ThemeColor = .triPhase(
        work: Color.white.opacity(0.85),
        shortBreak: Color.white.opacity(0.85),
        longBreak: Color.white.opacity(0.85)
    )
    
    let secondaryTextColor: ThemeColor = .triPhase(
        work: Color.white.opacity(0.55),
        shortBreak: Color.white.opacity(0.55),
        longBreak: Color.white.opacity(0.55)
    )
    
    let timerFont: Font = .system(size: 96, weight: .light, design: .rounded)
    
    // MARK: - Button Theme Properties
    
    let primaryButtonColor: ThemeColor = .triPhase(
        work: Color(red: 74/255, green: 144/255, blue: 226/255).opacity(0.7),
        shortBreak: Color(red: 80/255, green: 227/255, blue: 194/255).opacity(0.7),
        longBreak: Color(red: 245/255, green: 166/255, blue: 35/255).opacity(0.7)
    )
    
    let secondaryButtonColor: ThemeColor = .triPhase(
        work: Color.white.opacity(0.15),
        shortBreak: Color.white.opacity(0.15),
        longBreak: Color.white.opacity(0.15)
    )
    
    let buttonTextColor: ThemeColor = .triPhase(
        work: Color.white.opacity(0.9),
        shortBreak: Color.white.opacity(0.9),
        longBreak: Color.white.opacity(0.9)
    )
    
    let buttonHoverColor: ThemeColor = .triPhase(
        work: Color(red: 74/255, green: 144/255, blue: 226/255).opacity(0.85),
        shortBreak: Color(red: 80/255, green: 227/255, blue: 194/255).opacity(0.85),
        longBreak: Color(red: 245/255, green: 166/255, blue: 35/255).opacity(0.85)
    )
    
    let buttonShadowColor: Color = .clear
    
    // MARK: - Window Theme Properties
    
    let windowBackgroundType: WindowBackgroundType = .blur
    let windowBackgroundColor: Color = .clear
    
    // MARK: - Theme Experience Factory
    
    func createExperience() -> AnyThemeExperience {
        return AnyThemeExperience(AuraExperience())
    }
    
    // MARK: - Registration
    
    static func register() {
        ThemeRegistry.shared.register(AuraTheme())
    }
}

// MARK: - Aura Theme Experience

/// Aura theme experience with particle system and glassmorphism
struct AuraExperience: ThemeExperience {
    
    // MARK: - Behavioral Characteristics
    
    let allowsVisualControls = true
    let preferredInteractionModel = InteractionModel.minimal
    
    // MARK: - View Factories
    
    @ViewBuilder
    func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> some View {
        AuraThemeView(rippleTrigger: rippleTrigger)
            .environmentObject(viewModel)
    }
    
    @ViewBuilder
    func makeControlsView(viewModel: TimerViewModel) -> some View {
        AuraControlsView(viewModel: viewModel)
    }
}

// MARK: - Aura Theme View

/// The main Aura theme view with particle system and glassmorphism layers
struct AuraThemeView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @EnvironmentObject var screenContext: ScreenContext
    @Binding var rippleTrigger: Bool
    @State private var breathingScale: CGFloat = 1.0
    
    // Dynamic sizing properties
    private var timerFontSize: CGFloat {
        screenContext.scaledFont(baseSize: 96, minSize: 64, maxSize: 128)
    }
    
    private var stateLabelFontSize: CGFloat {
        screenContext.scaledFont(baseSize: 16, minSize: 12, maxSize: 20)
    }
    
    var body: some View {
        ZStack {
            // Revolutionary advanced particle system with environmental awareness
            AuraAdvancedParticleView()
                .environmentObject(viewModel)
                .environmentObject(screenContext)
                .ignoresSafeArea()
            
            // Glassmorphism base layer
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .opacity(0.3)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .frame(
                    width: screenContext.scaledSize(800, minSize: 600, maxSize: 1000),
                    height: screenContext.scaledSize(600, minSize: 400, maxSize: 800)
                )
            
            // Main content with foreground glass layer
            VStack(spacing: screenContext.scaledSize(40, minSize: 20, maxSize: 60)) {
                // Revolutionary focus awareness indicator
                AuraFocusIndicator()
                    .environmentObject(viewModel)
                    .environmentObject(screenContext)
                    .frame(height: screenContext.scaledSize(6, minSize: 4, maxSize: 8))
                // State label
                Text(viewModel.pomodoroState.currentPhase.rawValue.uppercased())
                    .font(.system(size: stateLabelFontSize, weight: .medium, design: .rounded))
                    .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                    .tracking(2.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: viewModel.pomodoroState.currentPhase)
                
                Spacer()
                
                // Timer display with enhanced glassmorphism
                ZStack {
                    // Foreground glass layer
                    VisualEffectView(material: .menu, blendingMode: .withinWindow)
                        .opacity(0.4)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .frame(
                            width: screenContext.scaledSize(400, minSize: 300, maxSize: 500),
                            height: screenContext.scaledSize(200, minSize: 150, maxSize: 250)
                        )
                    
                    // Timer text with legendary breathing animation
                    Text(viewModel.pomodoroState.formattedTime)
                        .font(.system(size: timerFontSize, weight: .light, design: .rounded))
                        .foregroundColor(viewModel.currentTheme.primaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                        .tracking(-2.0)
                        .scaleEffect(breathingScale)
                        .animation(.spring(response: 1.0, dampingFraction: 0.6), value: viewModel.pomodoroState.currentPhase)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        .onAppear {
                            startBreathingAnimation()
                        }
                        .onChange(of: viewModel.pomodoroState.isRunning) { isRunning in
                            if isRunning && viewModel.pomodoroState.currentPhase == .work {
                                startBreathingAnimation()
                            } else {
                                stopBreathingAnimation()
                            }
                        }
                }
                
                Spacer()
                
                // Progress indicator
                AuraProgressIndicator()
                    .environmentObject(viewModel)
                    .environmentObject(screenContext)
                    .frame(height: screenContext.scaledSize(8, minSize: 6, maxSize: 12))
                    .padding(.horizontal, screenContext.scaledSize(60, minSize: 40, maxSize: 80))
            }
            .padding(screenContext.scaledSize(60, minSize: 40, maxSize: 80))
            .frame(
                width: screenContext.scaledSize(800, minSize: 600, maxSize: 1000),
                height: screenContext.scaledSize(600, minSize: 400, maxSize: 800)
            )
        }
    }
    
    // MARK: - Legendary Breathing Animation
    
    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            breathingScale = 1.05
        }
    }
    
    private func stopBreathingAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            breathingScale = 1.0
        }
    }
}

// MARK: - Aura Controls View

/// Elegant glassmorphism controls for the Aura theme
struct AuraControlsView: View {
    @ObservedObject var viewModel: TimerViewModel
    @EnvironmentObject var screenContext: ScreenContext
    
    private var buttonSize: CGFloat {
        screenContext.scaledSize(50, minSize: 40, maxSize: 60)
    }
    
    private var iconSize: CGFloat {
        screenContext.scaledSize(18, minSize: 14, maxSize: 22)
    }
    
    var body: some View {
        HStack(spacing: screenContext.scaledSize(20, minSize: 16, maxSize: 24)) {
            // Play/Pause button
            AuraButton(
                icon: viewModel.pomodoroState.isRunning ? "pause.fill" : "play.fill",
                isPrimary: true,
                size: buttonSize,
                iconSize: iconSize
            ) {
                toggleTimer()
            }
            
            // Skip button
            AuraButton(
                icon: "forward.end.fill",
                isPrimary: false,
                size: buttonSize * 0.88,
                iconSize: iconSize * 0.9
            ) {
                viewModel.skipPhase()
            }
            
            // Reset button
            AuraButton(
                icon: "arrow.clockwise",
                isPrimary: false,
                size: buttonSize * 0.88,
                iconSize: iconSize * 0.9
            ) {
                viewModel.resetTimer()
            }
        }
    }
    
    private func toggleTimer() {
        if viewModel.pomodoroState.isRunning {
            viewModel.pauseTimer()
        } else {
            viewModel.startTimer()
        }
    }
}

// MARK: - Aura Button

/// Glassmorphism button with sophisticated hover and press states
struct AuraButton: View {
    let icon: String
    let isPrimary: Bool
    let size: CGFloat
    let iconSize: CGFloat
    let action: () -> Void
    
    @EnvironmentObject var viewModel: TimerViewModel
    @State private var isHovered = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isPressed = false
                }
                action()
            }
        }) {
            ZStack {
                // Glass background
                VisualEffectView(material: .menu, blendingMode: .withinWindow)
                    .opacity(isHovered ? 0.85 : 0.7)
                    .clipShape(Circle())
                
                // Icon
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundColor(
                        isPrimary 
                        ? viewModel.currentTheme.primaryButtonColor.color(for: viewModel.pomodoroState.currentPhase)
                        : viewModel.currentTheme.buttonTextColor.color(for: viewModel.pomodoroState.currentPhase)
                    )
                    .scaleEffect(isPressed ? 0.9 : (isHovered ? 1.1 : 1.0))
            }
            .frame(width: size, height: size)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isHovered = hovering
            }
        }
        .animation(.spring(response: 1.5, dampingFraction: 0.8), value: viewModel.pomodoroState.currentPhase)
    }
}

// MARK: - Aura Progress Indicator

/// Elegant progress bar that reflects the timer state
struct AuraProgressIndicator: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @EnvironmentObject var screenContext: ScreenContext
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                
                // Progress fill
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                viewModel.currentTheme.accentColor.color(for: viewModel.pomodoroState.currentPhase),
                                viewModel.currentTheme.primaryButtonColor.color(for: viewModel.pomodoroState.currentPhase)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * viewModel.pomodoroState.progress)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.pomodoroState.progress)
                    .animation(.spring(response: 1.2, dampingFraction: 0.8), value: viewModel.pomodoroState.currentPhase)
            }
        }
    }
}

// MARK: - Preview Support

#Preview("Aura Theme") {
    AuraThemeView(rippleTrigger: .constant(false))
        .environmentObject(TimerViewModel())
        .environmentObject(ScreenContext())
        .frame(width: 800, height: 600)
        .background(Color.black)
}