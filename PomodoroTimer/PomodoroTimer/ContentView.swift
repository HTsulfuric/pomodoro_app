import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    @State private var isFloatingMode = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with emoji and phase
            HStack {
                Text(viewModel.pomodoroState.currentPhase.emoji)
                    .font(.system(size: 32))
                Text(viewModel.pomodoroState.currentPhase.rawValue)
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .foregroundColor(.primary)
            
            // Main Timer Display
            VStack(spacing: 12) {
                // Large time display
                Text(viewModel.pomodoroState.formattedTime)
                    .font(.system(size: 64, weight: .thin, design: .monospaced))
                    .foregroundColor(.primary)
                
                // Progress bar
                ProgressView(value: viewModel.pomodoroState.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            .padding(.vertical)
            
            // Session info
            VStack(spacing: 8) {
                Text("Session \(viewModel.pomodoroState.sessionCount + 1)/4")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Today: \(viewModel.totalSessionsToday) sessions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Control buttons
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // Play/Pause button
                    Button(action: {
                        if viewModel.pomodoroState.isRunning {
                            viewModel.pauseTimer()
                        } else {
                            viewModel.startTimer()
                        }
                    }) {
                        Image(systemName: viewModel.pomodoroState.isRunning ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .frame(width: 60, height: 40)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    // Skip button
                    Button(action: {
                        viewModel.skipPhase()
                    }) {
                        Image(systemName: "forward.end.fill")
                            .font(.title3)
                            .frame(width: 60, height: 40)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                
                HStack(spacing: 16) {
                    // Reset button
                    Button(action: {
                        viewModel.resetTimer()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .frame(width: 60, height: 40)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    // Test Sound button
                    Button(action: {
                        print("🔊 Testing sound manually...")
                        SoundManager.shared.playPhaseChangeSound(for: .work)
                    }) {
                        Image(systemName: "speaker.2.fill")
                            .font(.title3)
                            .frame(width: 60, height: 40)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
            
            // Debug button for testing
            Button("🐛 Debug: 3s Timer") {
                viewModel.setDebugTimer()
                viewModel.startTimer()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .font(.caption)
            
            // Floating mode toggle
            Toggle("Floating Mode", isOn: $isFloatingMode)
                .toggleStyle(SwitchToggleStyle())
                .font(.caption)
                .foregroundColor(.secondary)
                .onChange(of: isFloatingMode) { value in
                    // TODO: Implement floating window mode
                    if let window = NSApplication.shared.windows.first {
                        window.level = value ? .floating : .normal
                    }
                }
            
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .frame(width: 320, height: 450)
}