import SwiftUI

/// Retro terminal theme with green-on-black hacker aesthetic and typing animations
struct TerminalThemeView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @Binding var rippleTrigger: Bool
    
    @State private var displayedLogs: [String] = []
    @State private var currentProgressBar: String = ""
    @State private var isTyping: Bool = false
    
    private var terminalColor: Color {
        viewModel.pomodoroState.currentPhase == .work ? 
            Color(red: 0, green: 1, blue: 0) :  // Work: Green
            Color(red: 1, green: 0.75, blue: 0) // Break: Amber
    }
    
    private var progressPercentage: Int {
        Int(viewModel.pomodoroState.progress * 100)
    }
    
    private var progressBarLength: Int { 20 }
    
    var body: some View {
        ZStack {
            // Black terminal background (fill available space)
            Rectangle()
                .fill(Color.black)
            
            // Horizontal layout optimized for wide terminal format
            HStack(spacing: 20) {
                // Left side: System logs and status
                VStack(alignment: .leading, spacing: 6) {
                    // Terminal header
                    Text("user@pomodoro:~$")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(terminalColor.opacity(0.8))
                    
                    // System logs (condensed)
                    ForEach(displayedLogs.prefix(6), id: \.self) { log in
                        Text(log)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(terminalColor.opacity(0.9))
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // ASCII Progress bar at bottom left
                    VStack(alignment: .leading, spacing: 3) {
                        Text(currentProgressBar)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(terminalColor)
                        
                        Text("STATUS: \(isTyping ? "PROCESSING..." : "READY")")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(terminalColor.opacity(0.6))
                    }
                }
                .frame(maxWidth: 180, alignment: .leading)
                
                Spacer()
                
                // Right side: Main timer display
                VStack(spacing: 8) {
                    Text(viewModel.pomodoroState.currentPhase.emoji)
                        .font(.system(size: 32))
                    
                    Text(viewModel.pomodoroState.formattedTime)
                        .font(.system(size: 52, weight: .bold, design: .monospaced))
                        .foregroundColor(terminalColor)
                        .monospacedDigit()
                    
                    Text(viewModel.pomodoroState.currentPhase.rawValue.uppercased())
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(terminalColor.opacity(0.7))
                        .tracking(2.0)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
            
            // Terminal cursor blink effect
            if isTyping {
                TerminalCursor(color: terminalColor)
            }
        }
        .background(Color.black)
        .border(terminalColor.opacity(0.3), width: 1)
        .onAppear(perform: initializeTerminal)
        .onChange(of: viewModel.pomodoroState.progress) { _, _ in
            updateProgressBar()
        }
        .onChange(of: viewModel.pomodoroState.currentPhase) { _, _ in
            initializeTerminal()
        }
        .onChange(of: rippleTrigger) { _, _ in
            addLogEntry("SIGNAL: timer_start_detected")
        }
    }
    
    private func initializeTerminal() {
        displayedLogs.removeAll()
        isTyping = true
        
        let phase = viewModel.pomodoroState.currentPhase
        let duration = phase == .work ? 25 : 5
        
        let initialLogs = [
            "INITIATING POMODORO SESSION...",
            "PROCESS_ID: \(Int.random(in: 1000...9999))",
            "SESSION_TYPE: \(phase.rawValue.uppercased()) (\(duration) MIN)",
            phase == .work ? "LOCKING FOCUS..." : "ENTERING BREAK MODE...",
            "BACKGROUND_ACTIVITY: enabled",
            "READY."
        ]
        
        typeLogEntries(initialLogs)
        updateProgressBar()
    }
    
    private func typeLogEntries(_ logs: [String]) {
        for (index, log) in logs.enumerated() {
            let delay = Double(index) * 0.8 // Stagger each log entry
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                typeText(log) {
                    if index == logs.count - 1 {
                        isTyping = false
                    }
                }
            }
        }
    }
    
    private func typeText(_ text: String, completion: @escaping () -> Void) {
        var displayedText = ""
        let characters = Array(text)
        
        for (index, char) in characters.enumerated() {
            let delay = Double(index) * 0.03 // Fast typing speed
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                displayedText.append(char)
                
                // Update the last log entry or add new one
                if let lastIndex = displayedLogs.indices.last {
                    displayedLogs[lastIndex] = displayedText
                } else {
                    displayedLogs.append(displayedText)
                }
                
                if index == characters.count - 1 {
                    completion()
                }
            }
        }
        
        // Add empty entry for typing into
        displayedLogs.append("")
    }
    
    private func addLogEntry(_ message: String) {
        isTyping = true
        typeText(message) {
            isTyping = false
        }
    }
    
    private func updateProgressBar() {
        let filledBlocks = Int(Double(progressBarLength) * viewModel.pomodoroState.progress)
        let emptyBlocks = progressBarLength - filledBlocks
        
        let filled = String(repeating: "█", count: filledBlocks)
        let empty = String(repeating: "░", count: emptyBlocks)
        
        currentProgressBar = "[\(filled)\(empty)] \(progressPercentage)%"
    }
}

/// Animated terminal cursor
struct TerminalCursor: View {
    let color: Color
    @State private var isVisible = true
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Rectangle()
                    .fill(color)
                    .frame(width: 8, height: 12)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
                            isVisible.toggle()
                        }
                    }
            }
            .padding(.trailing, 16)
            .padding(.bottom, 8)
        }
    }
}

#Preview {
    @Previewable @State var rippleTrigger = false
    
    TerminalThemeView(rippleTrigger: .constant(false))
        .frame(minWidth: 300, minHeight: 400)
        .environmentObject(TimerViewModel())
        .background(Color.black)
}