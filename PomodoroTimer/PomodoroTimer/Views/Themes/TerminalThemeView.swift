import SwiftUI

/// Sophisticated terminal theme with structured TUI layout and ASCII art timer display
struct TerminalThemeView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @Binding var rippleTrigger: Bool
    
    @State private var currentProgressBar: String = ""
    
    private var terminalColor: Color {
        viewModel.currentTheme.primaryTextColor.color(for: viewModel.pomodoroState.currentPhase)
    }
    
    private var progressPercentage: Int {
        Int(viewModel.pomodoroState.progress * 100)
    }
    
    private var sessionInfo: String {
        "Sessions Today: \(viewModel.totalSessionsToday)"
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
                    headerView(width: geometry.size.width)
                    
                    // Main content area
                    mainContentView(geometry: geometry)
                    
                    // Footer with controls
                    footerView(width: geometry.size.width)
                }
            }
        }
        .background(Color.black)
        .onAppear(perform: updateProgressBar)
        .onChange(of: viewModel.pomodoroState.progress) { _, _ in
            updateProgressBar()
        }
    }
    
    private func headerView(width: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("┌─ Pomodoro Timer ")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(terminalColor)
                
                // Let SwiftUI fill the space with repeating characters
                HStack(spacing: 0) {
                    ForEach(0..<200, id: \.self) { _ in
                        Text("─")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(terminalColor)
                    }
                }
                .clipped()
                
                Text(" \(sessionInfo) ┐")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(terminalColor)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func mainContentView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Main content area with side borders
            ZStack {
                // Central timer display
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Clean 7-segment timer display
                    segmentTimerView(geometry: geometry)
                    
                    // Phase indicator
                    Text("[ \(viewModel.pomodoroState.currentPhase.rawValue.uppercased()) ]")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(terminalColor)
                        .tracking(1.0)
                    
                    // Full-width progress bar
                    progressBarView(width: geometry.size.width)
                    
                    Spacer()
                }
                
                // Side borders overlay
                HStack(spacing: 0) {
                    Text("│")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(terminalColor)
                        .padding(.leading, 16)
                    
                    Spacer()
                    
                    Text("│")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(terminalColor)
                        .padding(.trailing, 16)
                }
            }
        }
    }
    
    private func segmentTimerView(geometry: GeometryProxy) -> some View {
        let timeString = viewModel.pomodoroState.formattedTime
        return Text(timeString)
            .font(.custom("DSEG7Classic-Bold", size: 48))
            .foregroundColor(terminalColor)
            .multilineTextAlignment(.center)
    }
    
    private func progressBarView(width: CGFloat) -> some View {
        VStack(spacing: 8) {
            Text(currentProgressBar)
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(terminalColor)
                .tracking(0.5)
        }
        .padding(.horizontal, 32)
    }
    
    private func footerView(width: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("└")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(terminalColor)
                
                // Let SwiftUI fill the space with repeating characters
                HStack(spacing: 0) {
                    ForEach(0..<200, id: \.self) { _ in
                        Text("─")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(terminalColor)
                    }
                }
                .clipped()
                
                Text("┘")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(terminalColor)
            }
            .padding(.horizontal, 16)
            
            // Keyboard controls
            HStack(spacing: 20) {
                Text("[S]pace: Start/Pause")
                Text("[R]eset")
                Text("[S]kip")
                Text("[O/ESC]: Hide")
            }
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(terminalColor.opacity(0.7))
            .padding(.top, 4)
            .padding(.bottom, 8)
        }
    }
    
    
    private func updateProgressBar() {
        let progressBarLength = 50 // Much longer progress bar for better visibility
        let filledBlocks = Int(Double(progressBarLength) * viewModel.pomodoroState.progress)
        let emptyBlocks = progressBarLength - filledBlocks
        
        let filled = String(repeating: "█", count: filledBlocks)
        let empty = String(repeating: "░", count: emptyBlocks)
        
        currentProgressBar = "[\(filled)\(empty)] \(progressPercentage)%"
    }
}

#Preview {
    @Previewable @State var rippleTrigger = false
    
    TerminalThemeView(rippleTrigger: .constant(false))
        .frame(minWidth: 800, minHeight: 600)
        .environmentObject(TimerViewModel())
        .background(Color.black)
}
