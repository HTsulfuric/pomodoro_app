import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    
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
            
            // Main Timer Display with Circular Progress
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.nordNight3.opacity(0.3), lineWidth: 12)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: viewModel.pomodoroState.progress)
                    .stroke(
                        Color.nordAccent,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: viewModel.pomodoroState.progress)
                
                // Timer content in center - vertical layout with emoji
                VStack(spacing: 8) {
                    // Phase emoji at top
                    Text(viewModel.pomodoroState.currentPhase.emoji)
                        .font(.system(size: 32))
                    
                    // Main timer display
                    Text(viewModel.pomodoroState.formattedTime)
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.nordPrimary)
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    
                    // Phase name (de-emphasized)
                    Text(viewModel.pomodoroState.currentPhase.rawValue.uppercased())
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.nordSecondary)
                        .tracking(1.5)
                }
            }
            .frame(width: 320, height: 320)
            .padding(.vertical, 16)
            
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
                    // Play/Pause button (primary)
                    Button(action: {
                        if viewModel.pomodoroState.isRunning {
                            viewModel.pauseTimer()
                        } else {
                            viewModel.startTimer()
                        }
                    }) {
                        Image(systemName: viewModel.pomodoroState.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.nordPrimary)
                            .frame(width: 50, height: 50)
                            .background(Color.nordAccent.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
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
                    .buttonStyle(PlainButtonStyle())
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
                    .buttonStyle(PlainButtonStyle())
                    
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
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            #if DEBUG
            VStack(spacing: 8) {
                // Debug button for testing (only visible in Debug builds)
                Button("🐛 Debug: 3s Timer") {
                    viewModel.setDebugTimer()
                    viewModel.startTimer()
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.nordSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.nordNight3.opacity(0.4))
                .clipShape(Capsule())
                
                // URL Scheme Test button
                Button("🔗 Test: URL Toggle") {
                    print("🎯 Testing URL scheme handler directly...")
                    let testURL = URL(string: "pomodoro://toggle")!
                    // Simulate URL scheme handling by directly calling timer methods
                    print("🔗 Simulating: \(testURL)")
                    print("🔗 URL scheme: \(testURL.scheme ?? "nil")")
                    print("🔗 URL host: \(testURL.host ?? "nil")")
                    
                    // Direct timer toggle (simulating what the URL handler would do)
                    if let command = testURL.host {
                        print("📥 Simulated URL command: \(command)")
                        switch command {
                        case "toggle":
                            print("🎯 Simulated handleToggleCommand")
                            if viewModel.pomodoroState.isRunning {
                                print("⏸️ Pausing timer via simulated URL command")
                                viewModel.pauseTimer()
                            } else {
                                print("▶️ Starting timer via simulated URL command")
                                viewModel.startTimer()
                            }
                            print("✅ Simulated handleToggleCommand completed")
                        default:
                            print("⚠️ Unknown simulated command: \(command)")
                        }
                    }
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.nordFrost0)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.nordNight3.opacity(0.4))
                .clipShape(Capsule())
            }
            #endif
            
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
        }
    }
}

#Preview {
    ContentView()
        .frame(minWidth: 300, minHeight: 400)
        .environmentObject(TimerViewModel())
}
