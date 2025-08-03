import Foundation

/// Manages system sleep prevention when the pomodoro overlay is visible
/// Uses modern ProcessInfo API for safe, automatic cleanup
class SleepPreventionManager {
    static let shared = SleepPreventionManager()
    
    // MARK: - Properties
    private var activity: NSObjectProtocol?
    private var isActive: Bool = false
    
    // MARK: - Initialization
    private init() {
    }
    
    deinit {
        // Ensure cleanup on deallocation
        stopPreventingSleep()
    }
    
    // MARK: - Public Interface
    
    /// Start preventing system sleep and display sleep (screensaver)
    /// Only starts if not already active to avoid duplicate assertions
    func startPreventingSleep() {
        guard !isActive else {
            return
        }
        
        let reason = "Pomodoro timer overlay is visible"
        
        // Use modern ProcessInfo API - automatically cleaned up when activity is deallocated
        // .idleDisplaySleepDisabled specifically prevents screensaver/display sleep
        activity = ProcessInfo.processInfo.beginActivity(
            options: .idleDisplaySleepDisabled,
            reason: reason
        )
        
        if activity != nil {
            isActive = true
            Logger.sleep("Sleep prevention started: \(reason)")
        } else {
            Logger.error("Failed to create sleep prevention activity", category: .sleep)
            isActive = false
        }
    }
    
    /// Stop preventing system sleep
    /// Safe to call multiple times
    func stopPreventingSleep() {
        guard isActive, let currentActivity = activity else {
            return
        }
        
        ProcessInfo.processInfo.endActivity(currentActivity)
        activity = nil
        isActive = false
        Logger.sleep("Sleep prevention stopped")
    }
    
    /// Current state of sleep prevention
    var isSleepPreventionActive: Bool {
        isActive
    }
}
