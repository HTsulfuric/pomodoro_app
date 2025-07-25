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
    
    /// Current theme experience for sophisticated behavioral architecture
    private var currentExperience: AnyThemeExperience {
        viewModel.currentTheme.experience
    }
    
    var body: some View {
        ZStack {
        VStack(spacing: 20) {
            Spacer()
            
            // Theme-controlled content view (timer display, animations, etc.)
            currentExperience.makeContentView(
                viewModel: viewModel,
                rippleTrigger: $rippleTrigger
            )
            .id("content-\(viewModel.currentTheme.rawValue)")
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentTheme)
            
            // Session info - now theme-aware
            VStack(spacing: 6) {
                Text("Session \(viewModel.pomodoroState.sessionCount + 1)/4")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(viewModel.currentTheme.primaryTextColor)
                
                Text("Today: \(viewModel.totalSessionsToday) sessions")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(viewModel.currentTheme.secondaryTextColor)
            }
            
            // Theme-controlled controls (buttons or EmptyView for terminal)
            currentExperience.makeControlsView(viewModel: viewModel)
                .id("controls-\(viewModel.currentTheme.rawValue)")
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentTheme)
            
            Spacer()
        }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .background(
                themeBackground
            )
            .edgesIgnoringSafeArea(.all)
            .preferredColorScheme(.dark)
            .id("theme-\(viewModel.currentTheme.rawValue)") // Explicit view identity for performance
            .transition(.opacity)
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
    
    /// Theme-aware background based on current theme settings
    @ViewBuilder
    private var themeBackground: some View {
        switch viewModel.currentTheme.windowBackgroundType {
        case .blur:
            // Minimal theme: keep existing blur effect with transparent background
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .background(TransparentBackground())
        case .solid:
            // Grid and Terminal themes: solid color backgrounds
            viewModel.currentTheme.windowBackgroundColor
        case .gradient:
            // Future enhancement: gradient backgrounds
            LinearGradient(
                colors: [
                    viewModel.currentTheme.windowBackgroundColor,
                    viewModel.currentTheme.windowBackgroundColor.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
}

#Preview {
    ContentView()
        .frame(minWidth: 300, minHeight: 400)
        .environmentObject(TimerViewModel())
}
