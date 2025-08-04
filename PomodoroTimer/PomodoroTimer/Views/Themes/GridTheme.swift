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
        AnyThemeExperience(GridExperience())
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
    func makeContentView(viewModel: AppCoordinator, rippleTrigger: Binding<Bool>) -> some View {
        GridThemeView(rippleTrigger: rippleTrigger)
            .environmentObject(viewModel)
    }
    
    @ViewBuilder
    func makeControlsView(viewModel: AppCoordinator) -> some View {
        StandardControlsView(viewModel: viewModel)
    }
}

// MARK: - Preview Support

#Preview("Grid Theme Controls") {
    StandardControlsView(viewModel: AppCoordinator())
        .frame(width: 300, height: 150)
        .background(Color.nordNight0.opacity(0.95))
}

#Preview("Grid Experience Content") {
    @Previewable @State var rippleTrigger = false
    let experience = GridExperience()
    
    experience.makeContentView(viewModel: AppCoordinator(), rippleTrigger: .constant(false))
        .frame(width: 400, height: 380)
        .background(Color.nordNight0.opacity(0.95))
}

// MARK: - GridThemeView (Consolidated)

/// A GitHub contribution graph inspired theme with discrete time squares
struct GridThemeView: View {
    @EnvironmentObject var viewModel: AppCoordinator
    @EnvironmentObject var screenContext: ScreenContext
    @Binding var rippleTrigger: Bool
    
    // MARK: - Dynamic Sizing Properties
    
    /// Main horizontal spacing between left and right sections
    private var mainSpacing: CGFloat {
        screenContext.elementSpacing * 1.2
    }
    
    /// Vertical spacing between elements
    private var elementSpacing: CGFloat {
        screenContext.elementSpacing * 0.8
    }
    
    /// Dynamic font size for phase emoji
    private var emojiFontSize: CGFloat {
        screenContext.scaledFont(
            baseSize: 56,
            minSize: 42,
            maxSize: 80
        )
    }
    
    /// Dynamic font size for main timer display
    private var timerFontSize: CGFloat {
        screenContext.scaledFont(
            baseSize: 32,
            minSize: 24,
            maxSize: 48
        )
    }
    
    /// Dynamic font size for phase name
    private var phaseNameFontSize: CGFloat {
        screenContext.scaledFont(
            baseSize: 12,
            minSize: 10,
            maxSize: 16
        )
    }
    
    /// Dynamic font size for session info
    private var sessionInfoLargeFontSize: CGFloat {
        screenContext.scaledFont(
            baseSize: 14,
            minSize: 12,
            maxSize: 18
        )
    }
    
    /// Dynamic font size for session info secondary text
    private var sessionInfoSmallFontSize: CGFloat {
        screenContext.scaledFont(
            baseSize: 12,
            minSize: 10,
            maxSize: 16
        )
    }
    
    /// Dynamic font size for progress percentage
    private var progressFontSize: CGFloat {
        screenContext.scaledFont(
            baseSize: 14,
            minSize: 11,
            maxSize: 18
        )
    }
    
    /// Dynamic padding for the entire view
    private var viewPadding: CGFloat {
        screenContext.contentPadding
    }
    
    var body: some View {
        // Horizontal layout with dynamic spacing
        HStack(spacing: mainSpacing) {
            // Left side: Timer info and session details
            VStack(spacing: elementSpacing) {
                // Phase emoji and timer with dynamic spacing
                VStack(spacing: elementSpacing * 0.5) {
                    Text(viewModel.pomodoroState.currentPhase.emoji)
                        .font(.system(size: emojiFontSize))
                    
                    Text(viewModel.pomodoroState.formattedTime)
                        .font(.system(size: timerFontSize, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.currentTheme.primaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                        .monospacedDigit()
                    
                    Text(viewModel.pomodoroState.currentPhase.rawValue.uppercased())
                        .font(.system(size: phaseNameFontSize, weight: .medium, design: .rounded))
                        .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                        .tracking(1.2)
                }
                
                Spacer()
                
                // Session progress info with dynamic font sizes
                VStack(spacing: elementSpacing * 0.3) {
                    Text("Session \(viewModel.pomodoroState.sessionCount + 1)/4")
                        .font(.system(size: sessionInfoLargeFontSize, weight: .semibold, design: .rounded))
                        .foregroundColor(viewModel.currentTheme.primaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                    
                    Text("Today: \(viewModel.totalSessionsToday)")
                        .font(.system(size: sessionInfoSmallFontSize, weight: .medium, design: .rounded))
                        .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                }
                
                // Simple ripple effect for this theme
                if rippleTrigger {
                    RippleIndicator()
                }
            }
            .frame(maxWidth: 160)
            
            // Right side: Grid visualization with dynamic spacing
            VStack(spacing: elementSpacing * 0.6) {
                if viewModel.pomodoroState.currentPhase == .work {
                    WorkGridView(
                        progress: viewModel.pomodoroState.progress,
                        accentColor: viewModel.currentTheme.accentColor.color(for: viewModel.pomodoroState.currentPhase),
                        screenContext: screenContext
                    )
                } else {
                    BreakGridView(
                        progress: viewModel.pomodoroState.progress,
                        accentColor: viewModel.currentTheme.accentColor.color(for: viewModel.pomodoroState.currentPhase),
                        screenContext: screenContext
                    )
                }
                
                // Progress percentage with dynamic font size
                Text("\(Int(viewModel.pomodoroState.progress * 100))%")
                    .font(.system(size: progressFontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(viewPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 5x5 grid for work sessions with spiral fill pattern
struct WorkGridView: View {
    let progress: Double
    let accentColor: Color
    let screenContext: ScreenContext
    
    private let gridSize = 5
    
    /// Dynamic square size based on screen context
    private var squareSize: CGFloat {
        screenContext.gridSquareSize
    }
    
    /// Dynamic spacing based on screen context
    private var squareSpacing: CGFloat {
        screenContext.gridSpacing
    }
    
    /// Spiral pattern starting from outside corners, moving inward
    private var spiralOrder: [Int] {
        // Pre-calculated spiral order for 5x5 grid (0-24)
        // Starts from top-left, goes clockwise inward
        [0, 1, 2, 3, 4,  // Top row
         9, 14, 19, 24,  // Right column
         23, 22, 21, 20, // Bottom row (right to left)
         15, 10, 5,      // Left column (bottom to top)
         6, 7, 8,        // Inner top row
         13, 18,         // Inner right column
         17, 16,         // Inner bottom row
         11,             // Inner left
         12]             // Center (final square)
    }
    
    var filledSquares: Int {
        Int(progress * 25) // 25 total squares for 25 minutes
    }
    
    var body: some View {
        VStack(spacing: squareSpacing) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: squareSpacing) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        let index = row * gridSize + col
                        let spiralPosition = spiralOrder.firstIndex(of: index) ?? 99
                        let isFilled = spiralPosition < filledSquares
                        
                        GridSquare(
                            isFilled: isFilled,
                            fillColor: accentColor,
                            size: squareSize
                        )
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: filledSquares)
    }
}

/// 1x5 row for break sessions
struct BreakGridView: View {
    let progress: Double
    let accentColor: Color
    let screenContext: ScreenContext
    
    /// Dynamic square size for break grid (slightly larger than work grid)
    private var squareSize: CGFloat {
        screenContext.gridSquareSize * 1.3
    }
    
    /// Dynamic spacing for break grid (slightly larger spacing)
    private var squareSpacing: CGFloat {
        screenContext.gridSpacing * 1.3
    }
    
    var filledSquares: Int {
        Int(progress * 5) // 5 total squares for 5 minutes
    }
    
    var body: some View {
        HStack(spacing: squareSpacing) {
            ForEach(0..<5, id: \.self) { index in
                GridSquare(
                    isFilled: index < filledSquares,
                    fillColor: accentColor,
                    size: squareSize
                )
            }
        }
        .animation(.easeInOut(duration: 0.5), value: filledSquares)
    }
}

/// Individual grid square component
struct GridSquare: View {
    let isFilled: Bool
    let fillColor: Color
    let size: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(isFilled ? fillColor : Color.gray.opacity(0.3))
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isFilled ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFilled)
    }
}

/// Simple ripple indicator for grid theme
struct RippleIndicator: View {
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Circle()
            .fill(Color.green.opacity(0.3))
            .frame(width: 60, height: 60)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    opacity = 0.0
                }
            }
    }
}

#Preview("GridThemeView Consolidated") {
    @Previewable @State var rippleTrigger = false
    
    GridThemeView(rippleTrigger: .constant(false))
        .frame(minWidth: 300, minHeight: 400)
        .environmentObject(AppCoordinator())
        .environmentObject(ScreenContext())
        .background(Color.black.opacity(0.8))
}
