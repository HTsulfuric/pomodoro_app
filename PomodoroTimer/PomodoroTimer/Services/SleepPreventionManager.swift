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
        print("🛡️ SleepPreventionManager initialized")
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
            print("🛡️ Sleep prevention already active")
            return
        }
        
        let reason = "Pomodoro timer overlay is visible"
        
        // Use modern ProcessInfo API - automatically cleaned up when activity is deallocated
        activity = ProcessInfo.processInfo.beginActivity(
            options: .userInitiated,
            reason: reason
        )
        
        isActive = true
        print("🛡️ Sleep prevention started: \(reason)")
    }
    
    /// Stop preventing system sleep
    /// Safe to call multiple times
    func stopPreventingSleep() {
        guard isActive, let currentActivity = activity else {
            print("🛡️ Sleep prevention not active")
            return
        }
        
        ProcessInfo.processInfo.endActivity(currentActivity)
        activity = nil
        isActive = false
        print("🛡️ Sleep prevention stopped")
    }
    
    /// Current state of sleep prevention
    var isSleepPreventionActive: Bool {
        return isActive
    }
}