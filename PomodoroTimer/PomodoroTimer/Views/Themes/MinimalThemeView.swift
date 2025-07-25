import SwiftUI

/// The classic circular progress timer theme - clean and minimal
struct MinimalThemeView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @Binding var rippleTrigger: Bool
    
    var body: some View {
        // Main Timer Display with Circular Progress - optimized for 320×450 tall format
        ZStack {
            // Background ring (slightly smaller for better proportions in tall window)
            Circle()
                .stroke(Color.nordNight3.opacity(0.3), lineWidth: 12)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: viewModel.pomodoroState.progress)
                .stroke(
                    viewModel.currentTheme.accentColor.color(for: viewModel.pomodoroState.currentPhase),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: viewModel.pomodoroState.progress)
            
            // Ripple effect - positioned to emanate from the timer ring center
            RippleView(trigger: rippleTrigger)
            
            // Timer content in center - vertical layout with emoji
            VStack(spacing: 10) {
                // Phase emoji at top
                Text(viewModel.pomodoroState.currentPhase.emoji)
                    .font(.system(size: 36))
                
                // Main timer display (larger in tall window)
                Text(viewModel.pomodoroState.formattedTime)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(viewModel.currentTheme.primaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                
                // Phase name (de-emphasized)
                Text(viewModel.pomodoroState.currentPhase.rawValue.uppercased())
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                    .tracking(1.5)
                
                // Progress percentage
                Text("\(Int(viewModel.pomodoroState.progress * 100))%")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase).opacity(0.8))
            }
        }
        .frame(width: 280, height: 280) // Slightly smaller to leave more room for session info
        .padding(.vertical, 20)
    }
}

#Preview {
    @Previewable @State var rippleTrigger = false
    
    MinimalThemeView(rippleTrigger: .constant(false))
        .frame(minWidth: 300, minHeight: 400)
        .environmentObject(TimerViewModel())
        .background(Color.black.opacity(0.8))
}