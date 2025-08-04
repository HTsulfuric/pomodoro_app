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
    
    let buttonShadowColor = Color(red: 0, green: 0.5, blue: 0)
    
    // MARK: - Window Theme Properties
    
    let windowBackgroundType: WindowBackgroundType = .solid
    let windowBackgroundColor: Color = .black
    
    // MARK: - Theme Experience Factory
    
    func createExperience() -> AnyThemeExperience {
        AnyThemeExperience(TerminalExperience())
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
    func makeContentView(viewModel: AppCoordinator, rippleTrigger: Binding<Bool>) -> some View {
        TerminalThemeView(rippleTrigger: rippleTrigger)
            .environmentObject(viewModel)
    }
    
    @ViewBuilder
    func makeControlsView(viewModel: AppCoordinator) -> some View {
        EmptyView()  // No visible controls - purely keyboard driven
    }
    
    // MARK: - Custom Keyboard Behaviors
    
    func customKeyboardBehavior(for keyCode: UInt16) -> KeyboardBehavior? {
        switch keyCode {
        case 46: // M key - could toggle minimal mode overlay within terminal
            return .enhanced(
                action: {
                    // Future enhancement: show/hide minimal stats overlay
                    Logger.keyboard("🖥️ Terminal: Enhanced info mode")
                },
                visualFeedback: "INFO_MODE"
            )
        case 18: // 1 key - could show session shortcuts
            return .enhanced(
                action: {
                    Logger.keyboard("🖥️ Terminal: Session shortcuts displayed")
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
    
    experience.makeContentView(viewModel: AppCoordinator(), rippleTrigger: .constant(false))
        .frame(width: 800, height: 600)
        .background(Color.black)
}

// MARK: - TerminalThemeView (Consolidated)

/// Sophisticated terminal theme with structured TUI layout and ASCII art timer display
struct TerminalThemeView: View {
    @EnvironmentObject var viewModel: AppCoordinator
    @EnvironmentObject var screenContext: ScreenContext
    @Binding var rippleTrigger: Bool
    
    @State private var currentProgressBar: String = ""
    
    // MARK: - Color Properties
    
    private var terminalColor: Color {
        viewModel.currentTheme.primaryTextColor.color(for: viewModel.pomodoroState.currentPhase)
    }
    
    // MARK: - Data Properties
    
    private var progressPercentage: Int {
        Int(viewModel.pomodoroState.progress * 100)
    }
    
    private var sessionInfo: String {
        "Sessions Today: \(viewModel.totalSessionsToday)"
    }
    
    // MARK: - Dynamic Sizing Properties
    
    /// Dynamic font sizes for terminal theme
    private var fontSizes: (timer: CGFloat, header: CGFloat, controls: CGFloat) {
        screenContext.terminalFontSizes
    }
    
    /// Dynamic font size for the main timer display
    private var timerFontSize: CGFloat {
        fontSizes.timer
    }
    
    /// Dynamic font size for header and footer borders
    private var headerFontSize: CGFloat {
        fontSizes.header
    }
    
    /// Dynamic font size for controls text
    private var controlsFontSize: CGFloat {
        fontSizes.controls
    }
    
    /// Dynamic font size for phase indicator
    private var phaseIndicatorFontSize: CGFloat {
        screenContext.scaledFont(
            baseSize: 18,
            minSize: 14,
            maxSize: 24
        )
    }
    
    /// Dynamic font size for progress bar
    private var progressBarFontSize: CGFloat {
        screenContext.scaledFont(
            baseSize: 16,
            minSize: 12,
            maxSize: 20
        )
    }
    
    /// Dynamic spacing between main sections
    private var sectionSpacing: CGFloat {
        screenContext.elementSpacing
    }
    
    /// Dynamic horizontal padding for content
    private var horizontalPadding: CGFloat {
        screenContext.contentPadding * 0.67 // Slightly less padding for terminal
    }
    
    /// Dynamic progress bar length based on screen width
    private var progressBarLength: Int {
        let baseLength = 50
        let screenWidth = screenContext.screenFrame.width
        
        // Scale progress bar length based on screen width
        // For larger screens, use longer progress bars
        let scaleFactor = screenWidth / 1920.0
        let scaledLength = Int(Double(baseLength) * scaleFactor)
        
        // Clamp between reasonable bounds
        return max(30, min(100, scaledLength))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black terminal background
                Rectangle()
                    .fill(Color.black)
                
                // Structured TUI layout with box-drawing characters
                VStack(spacing: 0) {
                    // Header with box-drawing characters
                    headerView()
                    
                    // Main content area
                    mainContentView(geometry: geometry)
                    
                    // Footer with controls
                    footerView()
                }
            }
        }
        .background(Color.black)
        .onAppear(perform: updateProgressBar)
        .onChange(of: viewModel.pomodoroState.progress) { _, _ in
            updateProgressBar()
        }
    }
    
    private func headerView() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("┌─ Pomodoro Timer ")
                    .font(.system(size: headerFontSize, design: .monospaced))
                    .foregroundColor(terminalColor)
                
                // Let SwiftUI fill the space with repeating characters
                HStack(spacing: 0) {
                    ForEach(0..<200, id: \.self) { _ in
                        Text("─")
                            .font(.system(size: headerFontSize, design: .monospaced))
                            .foregroundColor(terminalColor)
                    }
                }
                .clipped()
                
                Text(" \(sessionInfo) ┐")
                    .font(.system(size: headerFontSize, design: .monospaced))
                    .foregroundColor(terminalColor)
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
    
    private func mainContentView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Main content area with side borders
            ZStack {
                // Central timer display with dynamic spacing
                VStack(spacing: sectionSpacing) {
                    Spacer()
                    
                    // Clean 7-segment timer display
                    segmentTimerView()
                    
                    // Phase indicator with dynamic font size
                    Text("[ \(viewModel.pomodoroState.currentPhase.rawValue.uppercased()) ]")
                        .font(.system(size: phaseIndicatorFontSize, weight: .bold, design: .monospaced))
                        .foregroundColor(terminalColor)
                        .tracking(1.0)
                    
                    // Full-width progress bar
                    progressBarView()
                    
                    Spacer()
                }
                
                // Side borders overlay with dynamic font and padding
                HStack(spacing: 0) {
                    Text("│")
                        .font(.system(size: headerFontSize, design: .monospaced))
                        .foregroundColor(terminalColor)
                        .padding(.leading, horizontalPadding)
                    
                    Spacer()
                    
                    Text("│")
                        .font(.system(size: headerFontSize, design: .monospaced))
                        .foregroundColor(terminalColor)
                        .padding(.trailing, horizontalPadding)
                }
            }
        }
    }
    
    private func segmentTimerView() -> some View {
        let timeString = viewModel.pomodoroState.formattedTime
        return Text(timeString)
            .font(.custom("DSEG7Classic-Bold", size: timerFontSize))
            .foregroundColor(terminalColor)
            .multilineTextAlignment(.center)
    }
    
    private func progressBarView() -> some View {
        VStack(spacing: sectionSpacing * 0.33) {
            Text(currentProgressBar)
                .font(.system(size: progressBarFontSize, design: .monospaced))
                .foregroundColor(terminalColor)
                .tracking(0.5)
        }
        .padding(.horizontal, horizontalPadding * 1.33)
    }
    
    private func footerView() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("└")
                    .font(.system(size: headerFontSize, design: .monospaced))
                    .foregroundColor(terminalColor)
                
                // Let SwiftUI fill the space with repeating characters
                HStack(spacing: 0) {
                    ForEach(0..<200, id: \.self) { _ in
                        Text("─")
                            .font(.system(size: headerFontSize, design: .monospaced))
                            .foregroundColor(terminalColor)
                    }
                }
                .clipped()
                
                Text("┘")
                    .font(.system(size: headerFontSize, design: .monospaced))
                    .foregroundColor(terminalColor)
            }
            .padding(.horizontal, horizontalPadding)
            
            // Keyboard controls with dynamic font and spacing
            HStack(spacing: sectionSpacing) {
                Text("[S]pace: Start/Pause")
                Text("[R]eset")
                Text("[S]kip")
                Text("[O/ESC]: Hide")
            }
            .font(.system(size: controlsFontSize, design: .monospaced))
            .foregroundColor(terminalColor.opacity(0.7))
            .padding(.top, sectionSpacing * 0.2)
            .padding(.bottom, sectionSpacing * 0.33)
        }
    }
    
    private func updateProgressBar() {
        let barLength = progressBarLength // Dynamic length based on screen size
        let filledBlocks = Int(Double(barLength) * viewModel.pomodoroState.progress)
        let emptyBlocks = barLength - filledBlocks
        
        let filled = String(repeating: "█", count: filledBlocks)
        let empty = String(repeating: "░", count: emptyBlocks)
        
        currentProgressBar = "[\(filled)\(empty)] \(progressPercentage)%"
    }
}

#Preview("TerminalThemeView Consolidated") {
    @Previewable @State var rippleTrigger = false
    
    TerminalThemeView(rippleTrigger: .constant(false))
        .frame(minWidth: 800, minHeight: 600)
        .environmentObject(AppCoordinator())
        .environmentObject(ScreenContext())
        .background(Color.black)
}
