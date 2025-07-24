import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @State private var rippleTrigger: Bool = false
    
    // Version info computed properties
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    
    private var macOSVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion)"
    }
    
    var body: some View {
        ZStack {
        VStack(spacing: 20) {
            Spacer()
            
            // Theme-based Timer Display
            Group {
                switch viewModel.currentTheme {
                case .minimal:
                    MinimalThemeView(rippleTrigger: $rippleTrigger)
                case .grid:
                    GridThemeView(rippleTrigger: $rippleTrigger)
                case .terminal:
                    TerminalThemeView(rippleTrigger: $rippleTrigger)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentTheme)
            
            
            // Session info
            VStack(spacing: 6) {
                Text("Session \(viewModel.pomodoroState.sessionCount + 1)/4")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.nordPrimary)
                
                Text("Today: \(viewModel.totalSessionsToday) sessions")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.nordSecondary)
            }
            
            // Control buttons
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    // Play/Pause button (primary) with space key feedback
                    Button(action: {
                        toggleTimer()
                    }) {
                        Image(systemName: viewModel.pomodoroState.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.nordPrimary)
                            .frame(width: 50, height: 50)
                            .background(Color.nordAccent.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .buttonStyle(CircleHoverButtonStyle())
                    
                    // Skip button
                    Button(action: {
                        viewModel.skipPhase()
                    }) {
                        Image(systemName: "forward.end.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.nordPrimary)
                            .frame(width: 44, height: 44)
                            .background(Color.nordNight3.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(CircleHoverButtonStyle())
                }
                
                HStack(spacing: 20) {
                    // Reset button
                    Button(action: {
                        viewModel.resetTimer()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.nordPrimary)
                            .frame(width: 44, height: 44)
                            .background(Color.nordNight3.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(CircleHoverButtonStyle())
                    
                    // Test Sound button
                    Button(action: {
                        print("🔊 Testing sound manually...")
                        SoundManager.shared.playPhaseChangeSound(for: .work)
                    }) {
                        Image(systemName: "speaker.2.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.nordPrimary)
                            .frame(width: 44, height: 44)
                            .background(Color.nordNight3.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(CircleHoverButtonStyle())
                }
            }
            
            
            Spacer()
        }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .background(
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
            )
            .edgesIgnoringSafeArea(.all)
            .background(TransparentBackground())
            .preferredColorScheme(.dark)
            .onReceive(NotificationCenter.default.publisher(for: .spaceKeyStartPressed)) { _ in
                print("🌊 Timer start notification received - triggering ripple effect")
                // Toggle the boolean to trigger the animation in RippleView
                rippleTrigger.toggle()
            }
            
            // Version info overlay
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PomodoroTimer v\(appVersion)")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.nordMuted)
                        Text("macOS \(macOSVersion)")
                            .font(.system(size: 9, weight: .regular, design: .monospaced))
                            .foregroundColor(.nordNight3)
                    }
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.bottom, 12)
            }
            
            // Theme picker overlay
            ThemePickerView()
        }
    }
    
    // MARK: - Helper Functions
    
    /// Toggle timer without visual feedback (for button clicks)
    private func toggleTimer() {
        if viewModel.pomodoroState.isRunning {
            viewModel.pauseTimer()
        } else {
            viewModel.startTimer()
        }
    }
}

#Preview {
    ContentView()
        .frame(minWidth: 300, minHeight: 400)
        .environmentObject(TimerViewModel())
}
