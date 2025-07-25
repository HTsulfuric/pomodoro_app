import SwiftUI

/// A GitHub contribution graph inspired theme with discrete time squares
struct GridThemeView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @Binding var rippleTrigger: Bool
    
    var body: some View {
        // Horizontal layout optimized for square-ish 400×380 format
        HStack(spacing: 24) {
            // Left side: Timer info and session details
            VStack(spacing: 16) {
                // Phase emoji and timer
                VStack(spacing: 8) {
                    Text(viewModel.pomodoroState.currentPhase.emoji)
                        .font(.system(size: 56))
                    
                    Text(viewModel.pomodoroState.formattedTime)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.currentTheme.primaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                        .monospacedDigit()
                    
                    Text(viewModel.pomodoroState.currentPhase.rawValue.uppercased())
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                        .tracking(1.2)
                }
                
                Spacer()
                
                // Session progress info
                VStack(spacing: 6) {
                    Text("Session \(viewModel.pomodoroState.sessionCount + 1)/4")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(viewModel.currentTheme.primaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                    
                    Text("Today: \(viewModel.totalSessionsToday)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                }
                
                // Simple ripple effect for this theme
                if rippleTrigger {
                    RippleIndicator()
                }
            }
            .frame(maxWidth: 160)
            
            // Right side: Grid visualization
            VStack(spacing: 12) {
                if viewModel.pomodoroState.currentPhase == .work {
                    WorkGridView(
                        progress: viewModel.pomodoroState.progress,
                        accentColor: viewModel.currentTheme.accentColor.color(for: viewModel.pomodoroState.currentPhase)
                    )
                } else {
                    BreakGridView(
                        progress: viewModel.pomodoroState.progress,
                        accentColor: viewModel.currentTheme.accentColor.color(for: viewModel.pomodoroState.currentPhase)
                    )
                }
                
                // Progress percentage
                Text("\(Int(viewModel.pomodoroState.progress * 100))%")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 5x5 grid for work sessions with spiral fill pattern
struct WorkGridView: View {
    let progress: Double
    let accentColor: Color
    
    private let gridSize = 5
    private let squareSize: CGFloat = 28
    private let squareSpacing: CGFloat = 6
    
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
    
    private let squareSize: CGFloat = 36
    private let squareSpacing: CGFloat = 8
    
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
            .fill(isFilled ? fillColor : Color.nordNight3.opacity(0.3))
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.nordNight3.opacity(0.2), lineWidth: 1)
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

#Preview {
    @Previewable @State var rippleTrigger = false
    
    GridThemeView(rippleTrigger: .constant(false))
        .frame(minWidth: 300, minHeight: 400)
        .environmentObject(TimerViewModel())
        .background(Color.black.opacity(0.8))
}