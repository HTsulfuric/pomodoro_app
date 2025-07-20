import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    
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
            .foregroundColor(.nordPrimary)
            
            // Main Timer Display
            VStack(spacing: 12) {
                // Large time display
                Text(viewModel.pomodoroState.formattedTime)
                    .font(.system(size: 64, weight: .thin, design: .monospaced))
                    .foregroundColor(.nordPrimary)
                
                // Progress bar
                ProgressView(value: viewModel.pomodoroState.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .nordAccent))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            .padding(.vertical)
            
            // Session info
            VStack(spacing: 8) {
                Text("Session \(viewModel.pomodoroState.sessionCount + 1)/4")
                    .font(.headline)
                    .foregroundColor(.nordSecondary)
                
                Text("Today: \(viewModel.totalSessionsToday) sessions")
                    .font(.caption)
                    .foregroundColor(.nordSecondary)
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
            
            
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
        )
        .edgesIgnoringSafeArea(.all)
        .background(TransparentBackground())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .frame(minWidth: 300, minHeight: 400)
        .environmentObject(TimerViewModel())
}