import Foundation
import AppKit
import Combine

/// Advanced focus awareness system that detects user attention and app switching
/// Provides revolutionary environmental adaptation for the Aura theme
class FocusAwarenessManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = FocusAwarenessManager()
    
    // MARK: - Published Properties
    @Published var focusState: FocusState = .focused
    @Published var currentApp: String = ""
    @Published var distractionLevel: Double = 0.0  // 0.0 = focused, 1.0 = highly distracted
    
    // MARK: - Private Properties
    private var appObserver: NSObjectProtocol?
    private var workspaceNotificationCenter: NSWorkspace
    private var timer: Timer?
    private var focusHistory: [FocusEvent] = []
    private let distractingApps = Set([
        "Safari", "Google Chrome", "Firefox", "Arc",
        "Twitter", "Instagram", "TikTok", "YouTube",
        "Facebook", "Reddit", "Discord", "Slack",
        "Messages", "Mail", "WhatsApp", "Telegram",
        "Netflix", "Spotify", "Music", "Podcast"
    ])
    
    // MARK: - Initialization
    private init() {
        workspaceNotificationCenter = NSWorkspace.shared
        setupAppSwitchingDetection()
        startFocusAnalysis()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Focus States
    enum FocusState {
        case deepFocus      // User is in flow state, single app for extended period
        case focused        // Normal focus, productive apps active
        case switching      // Brief app switching, neutral state
        case distracted     // Distraction apps active
        case chaotic        // Frequent app switching, high cognitive load
    }
    
    struct FocusEvent {
        let appName: String
        let timestamp: Date
        let duration: TimeInterval
        let isDistracting: Bool
    }
    
    // MARK: - Public Interface
    
    /// Get the current distraction intensity for particle system
    func getParticleAgitation() -> Double {
        switch focusState {
        case .deepFocus:
            return 0.0  // Calm, focused particles
        case .focused:
            return 0.2  // Slight movement
        case .switching:
            return 0.5  // Moderate agitation
        case .distracted:
            return 0.8  // High agitation
        case .chaotic:
            return 1.0  // Maximum chaos
        }
    }
    
    /// Get focus-based color intensity modifier
    func getColorIntensity() -> Double {
        switch focusState {
        case .deepFocus:
            return 1.2  // Enhanced colors for deep focus
        case .focused:
            return 1.0  // Normal intensity
        case .switching:
            return 0.8  // Slightly muted
        case .distracted:
            return 0.6  // Muted colors
        case .chaotic:
            return 0.4  // Very muted
        }
    }
    
    /// Get particle birth rate modifier based on focus
    func getParticleBirthRateModifier() -> Double {
        switch focusState {
        case .deepFocus:
            return 1.5  // More particles for visual richness
        case .focused:
            return 1.0  // Normal rate
        case .switching:
            return 0.8  // Slightly reduced
        case .distracted:
            return 0.5  // Sparse particles
        case .chaotic:
            return 0.3  // Very few particles
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAppSwitchingDetection() {
        // Monitor frontmost application changes
        appObserver = workspaceNotificationCenter.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo,
                  let app = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                  let appName = app.localizedName else { return }
            
            self.handleAppSwitch(to: appName)
        }
        
        // Get current app
        if let frontmostApp = workspaceNotificationCenter.frontmostApplication {
            currentApp = frontmostApp.localizedName ?? "Unknown"
        }
    }
    
    private func handleAppSwitch(to appName: String) {
        let previousApp = currentApp
        currentApp = appName
        
        let isDistracting = distractingApps.contains(appName)
        let now = Date()
        
        // Record focus event
        if !previousApp.isEmpty {
            let duration = now.timeIntervalSince(focusHistory.last?.timestamp ?? now)
            let event = FocusEvent(
                appName: previousApp,
                timestamp: now,
                duration: duration,
                isDistracting: distractingApps.contains(previousApp)
            )
            focusHistory.append(event)
            
            // Keep only last 50 events for performance
            if focusHistory.count > 50 {
                focusHistory.removeFirst()
            }
        }
        
        // Update focus state based on current app and recent history
        updateFocusState()
        
        // Calculate distraction level
        updateDistractionLevel()
    }
    
    private func updateFocusState() {
        let recentEvents = getRecentEvents(seconds: 300) // Last 5 minutes
        let appSwitchCount = recentEvents.count
        let currentAppIsDistracting = distractingApps.contains(currentApp)
        
        // Determine focus state based on patterns
        if currentAppIsDistracting {
            focusState = .distracted
        } else if appSwitchCount > 20 {
            focusState = .chaotic
        } else if appSwitchCount > 10 {
            focusState = .switching
        } else if appSwitchCount < 3 && !currentAppIsDistracting {
            focusState = .deepFocus
        } else {
            focusState = .focused
        }
    }
    
    private func updateDistractionLevel() {
        let recentEvents = getRecentEvents(seconds: 180) // Last 3 minutes
        let distractingEvents = recentEvents.filter { $0.isDistracting }
        let distractingRatio = Double(distractingEvents.count) / max(Double(recentEvents.count), 1.0)
        
        // Smooth distraction level changes
        let targetDistraction = distractingRatio
        distractionLevel = distractionLevel * 0.7 + targetDistraction * 0.3
    }
    
    private func getRecentEvents(seconds: TimeInterval) -> [FocusEvent] {
        let cutoffTime = Date().addingTimeInterval(-seconds)
        return focusHistory.filter { $0.timestamp > cutoffTime }
    }
    
    private func startFocusAnalysis() {
        // Update focus analysis every 10 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.analyzeFocusPatterns()
        }
    }
    
    private func analyzeFocusPatterns() {
        updateFocusState()
        updateDistractionLevel()
    }
    
    private func cleanup() {
        if let observer = appObserver {
            workspaceNotificationCenter.notificationCenter.removeObserver(observer)
        }
        timer?.invalidate()
    }
}

// MARK: - Focus Quality Analytics

extension FocusAwarenessManager {
    
    /// Get focus quality score for the current session (0.0 to 1.0)
    func getFocusQualityScore() -> Double {
        let recentEvents = getRecentEvents(seconds: 1800) // Last 30 minutes
        guard !recentEvents.isEmpty else { return 1.0 }
        
        let focusedTime = recentEvents
            .filter { !$0.isDistracting }
            .reduce(0) { $0 + $1.duration }
        
        let totalTime = recentEvents.reduce(0) { $0 + $1.duration }
        
        return totalTime > 0 ? focusedTime / totalTime : 1.0
    }
    
    /// Get recommended break intensity based on focus patterns
    func getRecommendedBreakIntensity() -> Double {
        let qualityScore = getFocusQualityScore()
        let switchCount = getRecentEvents(seconds: 1800).count
        
        // High switch count = more intense break needed
        // Low quality = gentle break recommended
        if qualityScore < 0.5 && switchCount > 15 {
            return 1.0  // Full restoration break
        } else if qualityScore < 0.7 {
            return 0.7  // Medium break
        } else {
            return 0.4  // Light break
        }
    }
}