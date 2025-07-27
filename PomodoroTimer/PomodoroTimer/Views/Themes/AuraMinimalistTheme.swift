import SwiftUI
import AppKit

// MARK: - Aura Minimalist Theme Definition

/// The perfect Aura theme for Aerospace users: "Inform, Don't Interrupt"
/// Designed for keyboard-driven, efficiency-focused power users who need ambient awareness
struct AuraMinimalistTheme: ThemeDefinition {
    
    // MARK: - Theme Identity
    
    let id = "aura-minimalist"
    let displayName = "Aura"
    let description = "Minimal focus ring for Aerospace power users"
    let icon = "circle.circle"
    
    // MARK: - Atlassian Design System Color Palette
    
    let accentColor: ThemeColor = .triPhase(
        work: Color(red: 0/255, green: 82/255, blue: 204/255),        // Atlassian Blue #0052CC
        shortBreak: Color(red: 54/255, green: 179/255, blue: 126/255), // Atlassian Green #36B37E  
        longBreak: Color(red: 54/255, green: 179/255, blue: 126/255)   // Atlassian Green #36B37E
    )
    
    let backgroundColor: Color = .clear
    
    let primaryTextColor: ThemeColor = .triPhase(
        work: Color.white,
        shortBreak: Color.white,
        longBreak: Color.white
    )
    
    let secondaryTextColor: ThemeColor = .triPhase(
        work: Color.white.opacity(0.8),
        shortBreak: Color.white.opacity(0.8),
        longBreak: Color.white.opacity(0.8)
    )
    
    // SF Mono for aerospace users - monospaced, clean, professional
    let timerFont: Font = .system(.title, design: .monospaced, weight: .medium)
    
    // MARK: - Button Theme Properties (Minimal)
    
    let primaryButtonColor: ThemeColor = .triPhase(
        work: Color(red: 0/255, green: 82/255, blue: 204/255).opacity(0.8),
        shortBreak: Color(red: 54/255, green: 179/255, blue: 126/255).opacity(0.8),
        longBreak: Color(red: 54/255, green: 179/255, blue: 126/255).opacity(0.8)
    )
    
    let secondaryButtonColor: ThemeColor = .triPhase(
        work: Color(red: 151/255, green: 160/255, blue: 175/255).opacity(0.6), // Atlassian Gray
        shortBreak: Color(red: 151/255, green: 160/255, blue: 175/255).opacity(0.6),
        longBreak: Color(red: 151/255, green: 160/255, blue: 175/255).opacity(0.6)
    )
    
    let buttonTextColor: ThemeColor = .triPhase(
        work: Color.white,
        shortBreak: Color.white,
        longBreak: Color.white
    )
    
    let buttonHoverColor: ThemeColor = .triPhase(
        work: Color(red: 0/255, green: 82/255, blue: 204/255),
        shortBreak: Color(red: 54/255, green: 179/255, blue: 126/255),
        longBreak: Color(red: 54/255, green: 179/255, blue: 126/255)
    )
    
    let buttonShadowColor: Color = .clear
    
    // MARK: - Window Theme Properties
    
    let windowBackgroundType: WindowBackgroundType = .blur
    let windowBackgroundColor: Color = .clear
    
    // MARK: - Theme Experience Factory
    
    func createExperience() -> AnyThemeExperience {
        return AnyThemeExperience(AuraMinimalistExperience())
    }
    
    // MARK: - Registration
    
    static func register() {
        ThemeRegistry.shared.register(AuraMinimalistTheme())
    }
}

// MARK: - Aura Minimalist Experience

/// Aerospace-optimized experience: keyboard-first, minimal, unobtrusive
struct AuraMinimalistExperience: ThemeExperience {
    
    // MARK: - Behavioral Characteristics
    
    let allowsVisualControls = true
    let preferredInteractionModel = InteractionModel.minimal
    
    // MARK: - Full Layout Control (Revolutionary!)
    
    @ViewBuilder
    func makeFullLayoutView(viewModel: TimerViewModel, statusInfo: StatusInfo, rippleTrigger: Binding<Bool>) -> AnyView? {
        return AnyView(
            AuraMinimalistFullView(
                viewModel: viewModel,
                statusInfo: statusInfo,
                rippleTrigger: rippleTrigger
            )
        )
    }
    
    // MARK: - Legacy View Factories (unused when full layout is implemented)
    
    @ViewBuilder
    func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> some View {
        AuraMinimalistView(rippleTrigger: rippleTrigger)
            .environmentObject(viewModel)
    }
    
    @ViewBuilder
    func makeControlsView(viewModel: TimerViewModel) -> some View {
        // No persistent controls - everything is hover-reveal or keyboard
        EmptyView()
    }
}

// MARK: - Aura Minimalist View

/// The perfect Focus Ring: minimal, informative, unobtrusive
struct AuraMinimalistView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @EnvironmentObject var screenContext: ScreenContext
    @Binding var rippleTrigger: Bool
    
    @State private var isHovered = false
    @State private var ringScale: CGFloat = 1.0
    
    // Aerospace-friendly sizing - small and unobtrusive
    private var ringSize: CGFloat {
        screenContext.scaledSize(120, minSize: 100, maxSize: 140)
    }
    
    private var timerFontSize: CGFloat {
        screenContext.scaledFont(baseSize: 18, minSize: 16, maxSize: 22)
    }
    
    var body: some View {
        ZStack {
            // The Focus Ring - core of the design
            FocusRing()
                .environmentObject(viewModel)
                .environmentObject(screenContext)
                .frame(width: ringSize, height: ringSize)
                .scaleEffect(ringScale)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: ringScale)
            
            // Central Timer Display
            VStack(spacing: 4) {
                // Main timer
                Text(viewModel.pomodoroState.formattedTime)
                    .font(.system(size: timerFontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .opacity(viewModel.pomodoroState.isRunning ? 1.0 : 0.7)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.pomodoroState.isRunning)
                
                // Subtle phase indicator (only when hovered)
                if isHovered {
                    Text(viewModel.pomodoroState.currentPhase.rawValue.uppercased())
                        .font(.system(size: timerFontSize * 0.6, weight: .regular, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1.0)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
            
            // Hover-reveal controls (Atlassian-inspired)
            if isHovered {
                HoverControls()
                    .environmentObject(viewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isHovered = hovering
                ringScale = hovering ? 1.1 : 1.0
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Focus Ring

/// The revolutionary progress ring that communicates everything at a glance
struct FocusRing: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @EnvironmentObject var screenContext: ScreenContext
    
    private var ringColor: Color {
        if !viewModel.pomodoroState.isRunning {
            return Color(red: 151/255, green: 160/255, blue: 175/255) // Atlassian Gray for paused
        }
        
        switch viewModel.pomodoroState.currentPhase {
        case .work:
            return Color(red: 0/255, green: 82/255, blue: 204/255) // Atlassian Blue
        case .shortBreak, .longBreak:
            return Color(red: 54/255, green: 179/255, blue: 126/255) // Atlassian Green
        }
    }
    
    private var progress: Double {
        return viewModel.pomodoroState.progress
    }
    
    var body: some View {
        ZStack {
            // Subtle glassmorphism background
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .clipShape(Circle())
                .opacity(0.3)
            
            // Background ring track
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 3)
            
            // Progress ring (depletes clockwise)
            Circle()
                .trim(from: 0, to: 1.0 - progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // Start from top
                .animation(.spring(response: 0.8, dampingFraction: 0.9), value: progress)
                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: viewModel.pomodoroState.currentPhase)
        }
    }
}

// MARK: - Hover Controls

/// Minimal controls that appear on hover - Atlassian Design System inspired
struct HoverControls: View {
    @EnvironmentObject var viewModel: TimerViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            // Play/Pause (primary action)
            MinimalControlButton(
                icon: viewModel.pomodoroState.isRunning ? "pause.fill" : "play.fill",
                isPrimary: true
            ) {
                toggleTimer()
            }
            
            // Reset (secondary action)
            MinimalControlButton(
                icon: "arrow.clockwise",
                isPrimary: false
            ) {
                viewModel.resetTimer()
            }
        }
        .offset(y: 50) // Below the ring
    }
    
    private func toggleTimer() {
        if viewModel.pomodoroState.isRunning {
            viewModel.pauseTimer()
        } else {
            viewModel.startTimer()
        }
    }
}

// MARK: - Minimal Control Button

/// Clean, Atlassian-inspired button for hover controls
struct MinimalControlButton: View {
    let icon: String
    let isPrimary: Bool
    let action: () -> Void
    
    @EnvironmentObject var viewModel: TimerViewModel
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(buttonColor)
                        .opacity(isPressed ? 0.8 : 1.0)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isPressed = false
                }
            }
        }
    }
    
    private var buttonColor: Color {
        if isPrimary {
            switch viewModel.pomodoroState.currentPhase {
            case .work:
                return Color(red: 0/255, green: 82/255, blue: 204/255) // Atlassian Blue
            case .shortBreak, .longBreak:
                return Color(red: 54/255, green: 179/255, blue: 126/255) // Atlassian Green
            }
        } else {
            return Color(red: 151/255, green: 160/255, blue: 175/255) // Atlassian Gray
        }
    }
}

// MARK: - Aura Minimalist Full View

/// Revolutionary full layout control for aerospace users
/// This view has complete control over EVERYTHING - no hardcoded status messages!
struct AuraMinimalistFullView: View {
    @ObservedObject var viewModel: TimerViewModel
    let statusInfo: StatusInfo
    @Binding var rippleTrigger: Bool
    
    @EnvironmentObject var screenContext: ScreenContext
    @State private var isHovered = false
    @State private var ringScale: CGFloat = 1.0
    
    // Aerospace-friendly sizing - small and unobtrusive
    private var ringSize: CGFloat {
        screenContext.scaledSize(120, minSize: 100, maxSize: 140)
    }
    
    private var timerFontSize: CGFloat {
        screenContext.scaledFont(baseSize: 18, minSize: 16, maxSize: 22)
    }
    
    private var statusFontSize: CGFloat {
        screenContext.scaledFont(baseSize: 12, minSize: 10, maxSize: 14)
    }
    
    var body: some View {
        ZStack {
            // Perfect positioning for aerospace workflow
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    // The Focus Ring - perfectly centered
                    VStack(spacing: 12) {
                        // Main focus ring
                        ZStack {
                            FocusRing()
                                .environmentObject(viewModel)
                                .environmentObject(screenContext)
                                .frame(width: ringSize, height: ringSize)
                                .scaleEffect(ringScale)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: ringScale)
                            
                            // Central Timer Display
                            VStack(spacing: 4) {
                                // Main timer
                                Text(statusInfo.formattedTime)
                                    .font(.system(size: timerFontSize, weight: .medium, design: .monospaced))
                                    .foregroundColor(.white)
                                    .opacity(statusInfo.isRunning ? 1.0 : 0.7)
                                    .animation(.easeInOut(duration: 0.3), value: statusInfo.isRunning)
                                
                                // Subtle phase indicator (only when hovered)
                                if isHovered {
                                    Text(statusInfo.currentPhase.rawValue.uppercased())
                                        .font(.system(size: timerFontSize * 0.6, weight: .regular, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.6))
                                        .tracking(1.0)
                                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                                }
                            }
                            
                            // Hover-reveal controls (Atlassian-inspired)
                            if isHovered {
                                HoverControls()
                                    .environmentObject(viewModel)
                                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                            }
                        }
                        .onHover { hovering in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isHovered = hovering
                                ringScale = hovering ? 1.1 : 1.0
                            }
                        }
                        
                        // Ultra-minimal status for aerospace users (only session count)
                        if statusInfo.isRunning || isHovered {
                            Text(statusInfo.sessionDisplayText)
                                .font(.system(size: statusFontSize, weight: .regular, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                                .tracking(0.5)
                                .transition(.opacity.combined(with: .offset(y: 5)))
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            // NO version info overlay - aerospace users don't need visual clutter!
            // NO persistent session info - only shows when relevant
            // This is the PERFECT design for focused productivity
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: statusInfo.currentPhase)
    }
}

// MARK: - Preview Support

#Preview("Aura Minimalist") {
    AuraMinimalistView(rippleTrigger: .constant(false))
        .environmentObject(TimerViewModel())
        .environmentObject(ScreenContext())
        .frame(width: 300, height: 300)
        .background(Color.black)
}

#Preview("Aura Minimalist Full Layout") {
    let viewModel = TimerViewModel()
    let statusInfo = StatusInfo.from(viewModel: viewModel)
    
    AuraMinimalistFullView(
        viewModel: viewModel,
        statusInfo: statusInfo,
        rippleTrigger: .constant(false)
    )
    .environmentObject(ScreenContext())
    .frame(width: 400, height: 300)
    .background(Color.black)
}