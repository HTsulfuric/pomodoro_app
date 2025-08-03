import Foundation

// MARK: - Status Information

/// Comprehensive status information that themes can choose to display
/// This provides themes with all the dynamic data they might need for status displays
struct StatusInfo {
    // MARK: - Session Information
    
    /// Current session number (1-based, e.g., "Session 2/4")
    let currentSession: Int
    
    /// Total sessions completed today
    let totalSessionsToday: Int
    
    /// Current phase of the pomodoro cycle
    let currentPhase: PomodoroPhase
    
    /// Whether the timer is currently running
    let isRunning: Bool
    
    /// Timer progress (0.0 to 1.0)
    let progress: Double
    
    /// Formatted time remaining (e.g., "25:00")
    let formattedTime: String
    
    // MARK: - Application Information
    
    /// App version string (e.g., "1.2.0")
    let appVersion: String
    
    /// macOS version string (e.g., "14.2")
    let macOSVersion: String
    
    /// Current theme identifier
    let currentThemeId: String
}

// MARK: - Convenience Extensions

extension StatusInfo {
    /// Creates StatusInfo from TimerViewModel and system information
    static func from(
        viewModel: TimerViewModel,
        appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
        macOSVersion: String = {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            return "\(version.majorVersion).\(version.minorVersion)"
        }()
    ) -> StatusInfo {
        StatusInfo(
            currentSession: viewModel.pomodoroState.sessionCount + 1,
            totalSessionsToday: viewModel.totalSessionsToday,
            currentPhase: viewModel.pomodoroState.currentPhase,
            isRunning: viewModel.pomodoroState.isRunning,
            progress: viewModel.pomodoroState.progress,
            formattedTime: viewModel.pomodoroState.formattedTime,
            appVersion: appVersion,
            macOSVersion: macOSVersion,
            currentThemeId: viewModel.currentTheme.id
        )
    }
    
    /// Session display string (e.g., "Session 2/4")
    var sessionDisplayText: String {
        "Session \(currentSession)/4"
    }
    
    /// Today's sessions display string (e.g., "Today: 12 sessions")
    var todaySessionsDisplayText: String {
        "Today: \(totalSessionsToday) sessions"
    }
    
    /// App version display string (e.g., "PomodoroTimer v1.2.0")
    var appVersionDisplayText: String {
        "PomodoroTimer v\(appVersion)"
    }
    
    /// macOS version display string (e.g., "macOS 14.2")
    var macOSVersionDisplayText: String {
        "macOS \(macOSVersion)"
    }
}
