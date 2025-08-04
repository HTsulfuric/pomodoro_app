import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AppCoordinator
    @EnvironmentObject var screenContext: ScreenContext
    @State private var rippleTrigger: Bool = false
    
    // Cached theme experience to prevent memory allocation churn
    @State private var cachedExperience: AnyThemeExperience?
    @State private var cachedThemeId: String?
    
    // Cached font sizes to prevent expensive logarithmic calculations on every render
    @State private var cachedFontSizes: [String: CGFloat] = [:]
    @State private var cachedScreenSize: CGSize = .zero
    
    // Version info computed properties
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var macOSVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion)"
    }
    
    /// Cached theme experience with intelligent memoization to prevent allocation churn
    private var currentExperience: AnyThemeExperience {
        let currentThemeId = viewModel.currentTheme.id
        
        // Only create new experience if theme changed or cache is empty
        if cachedThemeId != currentThemeId || cachedExperience == nil {
            let newExperience = viewModel.currentTheme.createExperience()
            
            // Update cache on next render cycle to avoid state mutations during view updates
            DispatchQueue.main.async {
                self.cachedExperience = newExperience
                self.cachedThemeId = currentThemeId
            }
            
            return newExperience
        }
        
        return cachedExperience!
    }
    
    /// Get font size with caching - uses direct calculation to avoid state mutation during view updates
    private func getCachedFontSize(key: String, baseSize: CGFloat, minSize: CGFloat, maxSize: CGFloat) -> CGFloat {
        let currentScreenSize = screenContext.screenFrame.size
        
        // Check if screen size changed and cache is invalid
        if currentScreenSize != cachedScreenSize || cachedFontSizes.isEmpty {
            // Use direct calculation without modifying state during view update
            return screenContext.scaledFont(baseSize: baseSize, minSize: minSize, maxSize: maxSize)
        }
        
        // Return cached value if available, otherwise calculate directly
        return cachedFontSizes[key] ?? screenContext.scaledFont(baseSize: baseSize, minSize: minSize, maxSize: maxSize)
    }
    
    /// Update font cache when screen geometry changes
    private func updateFontCache() {
        let currentScreenSize = screenContext.screenFrame.size
        
        if currentScreenSize != cachedScreenSize {
            cachedFontSizes.removeAll()
            cachedScreenSize = currentScreenSize
            
            // Pre-populate cache with commonly used font sizes
            cachedFontSizes["sessionLarge"] = screenContext.scaledFont(baseSize: 18, minSize: 14, maxSize: 24)
            cachedFontSizes["sessionSmall"] = screenContext.scaledFont(baseSize: 14, minSize: 11, maxSize: 18)
            cachedFontSizes["versionLarge"] = screenContext.scaledFont(baseSize: 10, minSize: 8, maxSize: 13)
            cachedFontSizes["versionSmall"] = screenContext.scaledFont(baseSize: 9, minSize: 7, maxSize: 12)
        }
    }
    
    // MARK: - Dynamic Sizing Properties
    
    /// Cached dynamic font size for session info primary text
    private var sessionInfoLargeFontSize: CGFloat {
        getCachedFontSize(key: "sessionLarge", baseSize: 18, minSize: 14, maxSize: 24)
    }
    
    /// Cached dynamic font size for session info secondary text
    private var sessionInfoSmallFontSize: CGFloat {
        getCachedFontSize(key: "sessionSmall", baseSize: 14, minSize: 11, maxSize: 18)
    }
    
    /// Cached dynamic font size for version info
    private var versionInfoLargeFontSize: CGFloat {
        getCachedFontSize(key: "versionLarge", baseSize: 10, minSize: 8, maxSize: 13)
    }
    
    /// Cached dynamic font size for version info secondary
    private var versionInfoSmallFontSize: CGFloat {
        getCachedFontSize(key: "versionSmall", baseSize: 9, minSize: 7, maxSize: 12)
    }
    
    /// Dynamic spacing between session info elements
    private var sessionInfoSpacing: CGFloat {
        screenContext.elementSpacing * 0.3
    }
    
    /// Dynamic spacing between main sections
    private var mainSectionSpacing: CGFloat {
        screenContext.elementSpacing
    }
    
    /// Dynamic version info spacing
    private var versionInfoSpacing: CGFloat {
        screenContext.elementSpacing * 0.1
    }
    
    /// Dynamic padding for version and theme picker overlays
    private var overlayPadding: CGFloat {
        screenContext.contentPadding * 0.67
    }
    
    var body: some View {
        let statusInfo = StatusInfo.from(viewModel: viewModel, appVersion: appVersion, macOSVersion: macOSVersion)
        
        ZStack {
            // Check if theme supports full layout control
            if let fullLayoutView = currentExperience.makeFullLayoutView(
                viewModel: viewModel,
                statusInfo: statusInfo,
                rippleTrigger: $rippleTrigger
            ) {
                // Theme has complete control over layout
                fullLayoutView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(themeBackground)
                    .edgesIgnoringSafeArea(.all)
                    .preferredColorScheme(.dark)
                    .id("theme-\(viewModel.currentTheme.id)")
                    .transition(.opacity)
            } else {
                // Use default layout system (backward compatibility)
                VStack(spacing: mainSectionSpacing) {
                    Spacer()
                    
                    // Theme-controlled content view (timer display, animations, etc.)
                    currentExperience.makeContentView(
                        viewModel: viewModel,
                        rippleTrigger: $rippleTrigger
                    )
                    .id("content-\(viewModel.currentTheme.id)")
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentTheme.id)
                    
                    // Session info with dynamic sizing and colors
                    VStack(spacing: sessionInfoSpacing) {
                        Text(statusInfo.sessionDisplayText)
                            .font(.system(size: sessionInfoLargeFontSize, weight: .semibold, design: .rounded))
                            .foregroundColor(viewModel.currentTheme.primaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                        
                        Text(statusInfo.todaySessionsDisplayText)
                            .font(.system(size: sessionInfoSmallFontSize, weight: .medium, design: .rounded))
                            .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                    }
                    
                    // Theme-controlled controls (buttons or EmptyView for terminal)
                    currentExperience.makeControlsView(viewModel: viewModel)
                        .id("controls-\(viewModel.currentTheme.id)")
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentTheme.id)
                    
                    Spacer()
                }
                .padding(screenContext.contentPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .background(themeBackground)
                .edgesIgnoringSafeArea(.all)
                .preferredColorScheme(.dark)
                .id("theme-\(viewModel.currentTheme.id)")
                .transition(.opacity)
                
                // Version info overlay with dynamic sizing (only for default layout)
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: versionInfoSpacing) {
                            Text(statusInfo.appVersionDisplayText)
                                .font(.system(size: versionInfoLargeFontSize, weight: .medium, design: .monospaced))
                                .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase).opacity(0.6))
                            Text(statusInfo.macOSVersionDisplayText)
                                .font(.system(size: versionInfoSmallFontSize, weight: .regular, design: .monospaced))
                                .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase).opacity(0.4))
                        }
                        Spacer()
                    }
                    .padding(.leading, overlayPadding)
                    .padding(.bottom, overlayPadding * 0.5)
                }
            }
            
            // Theme picker overlay (replaced with EmptyView - use T key for text-based picker)
            EmptyView()
            
            // Text-based theme picker overlay (nnn/yazi style)
            if viewModel.isThemePickerPresented {
                TextBasedThemePickerView()
                    .environmentObject(viewModel)
                    .transition(.opacity)
                    .zIndex(1000) // Ensure it appears above everything else
            }
        }
        // Consolidated notification handling to eliminate overhead from multiple onReceive calls
        .onReceive(NotificationCenter.default.publisher(for: .spaceKeyStartPressed)) { _ in
            Logger.debug("🌊 Timer start notification received - triggering ripple effect", category: .ui)
            rippleTrigger.toggle()
        }
        // Update font cache when screen context changes
        .onReceive(screenContext.objectWillChange) { _ in
            updateFontCache()
        }
        .onAppear {
            updateFontCache()
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
        .environmentObject(AppCoordinator())
        .environmentObject(ScreenContext())
}
