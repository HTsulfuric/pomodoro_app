import SwiftUI

/// The classic circular progress timer theme - clean and minimal
struct MinimalThemeView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @EnvironmentObject var screenContext: ScreenContext
    @Binding var rippleTrigger: Bool
    
    // MARK: - Dynamic Sizing Properties
    
    /// Circle specifications based on current screen
    private var circleSpecs: (diameter: CGFloat, lineWidth: CGFloat) {
        return screenContext.minimalCircleSpecs
    }
    
    /// Dynamic font size for main timer display
    private var timerFontSize: CGFloat {
        return screenContext.scaledFont(
            baseSize: 64,
            minSize: 48,
            maxSize: 96
        )
    }
    
    /// Dynamic font size for phase emoji
    private var emojiFontSize: CGFloat {
        return screenContext.scaledFont(
            baseSize: 36,
            minSize: 28,
            maxSize: 52
        )
    }
    
    /// Dynamic font size for phase name
    private var phaseNameFontSize: CGFloat {
        return screenContext.scaledFont(
            baseSize: 15,
            minSize: 12,
            maxSize: 20
        )
    }
    
    /// Dynamic font size for progress percentage
    private var progressFontSize: CGFloat {
        return screenContext.scaledFont(
            baseSize: 12,
            minSize: 10,
            maxSize: 16
        )
    }
    
    /// Dynamic spacing between elements
    private var elementSpacing: CGFloat {
        return screenContext.elementSpacing
    }
    
    /// Dynamic padding for the entire view
    private var viewPadding: CGFloat {
        return screenContext.contentPadding
    }
    
    var body: some View {
        // Main Timer Display with Circular Progress - dynamically sized for current screen
        ZStack {
            // Background ring with dynamic sizing
            Circle()
                .stroke(viewModel.currentTheme.secondaryButtonColor.color(for: viewModel.pomodoroState.currentPhase), lineWidth: circleSpecs.lineWidth)
            
            // Progress ring with dynamic sizing
            Circle()
                .trim(from: 0, to: viewModel.pomodoroState.progress)
                .stroke(
                    viewModel.currentTheme.accentColor.color(for: viewModel.pomodoroState.currentPhase),
                    style: StrokeStyle(lineWidth: circleSpecs.lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: viewModel.pomodoroState.progress)
            
            // Ripple effect - positioned to emanate from the timer ring center
            RippleView(trigger: rippleTrigger)
            
            // Timer content in center - vertical layout with emoji (dynamic spacing)
            VStack(spacing: elementSpacing * 0.5) {
                // Phase emoji at top with dynamic size
                Text(viewModel.pomodoroState.currentPhase.emoji)
                    .font(.system(size: emojiFontSize))
                
                // Main timer display with dynamic font size
                Text(viewModel.pomodoroState.formattedTime)
                    .font(.system(size: timerFontSize, weight: .bold, design: .rounded))
                    .foregroundColor(viewModel.currentTheme.primaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                
                // Phase name with dynamic font size
                Text(viewModel.pomodoroState.currentPhase.rawValue.uppercased())
                    .font(.system(size: phaseNameFontSize, weight: .medium, design: .rounded))
                    .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                    .tracking(1.5)
                
                // Progress percentage with dynamic font size
                Text("\(Int(viewModel.pomodoroState.progress * 100))%")
                    .font(.system(size: progressFontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase).opacity(0.8))
            }
        }
        .frame(width: circleSpecs.diameter, height: circleSpecs.diameter) // Dynamic sizing based on screen
        .padding(.vertical, viewPadding)
    }
}

#Preview {
    @Previewable @State var rippleTrigger = false
    
    MinimalThemeView(rippleTrigger: .constant(false))
        .frame(minWidth: 300, minHeight: 400)
        .environmentObject(TimerViewModel())
        .environmentObject(ScreenContext())
        .background(Color.black.opacity(0.8))
}