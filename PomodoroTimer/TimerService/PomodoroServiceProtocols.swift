import Foundation

// MARK: - Service Protocol (Commands from clients to service)

/// Protocol defining commands that clients can send to the Pomodoro XPC service
@objc protocol PomodoroServiceProtocol {
    /// Toggle timer state (start if paused, pause if running)
    /// - Parameter reply: Completion handler with success status
    func toggleTimer(reply: @escaping (Bool) -> Void)
    
    /// Reset the current timer session
    /// - Parameter reply: Completion handler with success status
    func resetTimer(reply: @escaping (Bool) -> Void)
    
    /// Skip to the next phase (work → break, break → work)
    /// - Parameter reply: Completion handler with success status  
    func skipPhase(reply: @escaping (Bool) -> Void)
    
    /// Get the current timer state (simplified for CLI)
    /// - Parameter reply: Completion handler with service responsiveness status
    func getCurrentState(reply: @escaping (Bool) -> Void)
}

// MARK: - Client Protocol (Updates from service to main app)

/// Protocol defining callbacks that the service can send to the main app UI
@objc protocol PomodoroClientProtocol {
    /// Called when the timer state changes using simple Foundation types
    func pomodoroStateDidChange(phase: String, timeRemaining: TimeInterval, sessionCount: Int, isRunning: Bool, isPaused: Bool)
}