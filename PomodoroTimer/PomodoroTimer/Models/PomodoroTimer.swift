import Foundation

enum PomodoroPhase: String, CaseIterable {
    case work = "Work Session"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
    
    var duration: TimeInterval {
        switch self {
        case .work: return 25 * 60 // 25 minutes
        case .shortBreak: return 5 * 60 // 5 minutes
        case .longBreak: return 15 * 60 // 15 minutes
        }
    }
    
    var emoji: String {
        switch self {
        case .work: return "🍅"
        case .shortBreak: return "☕️"
        case .longBreak: return "🏖️"
        }
    }
    
    var nextPhase: PomodoroPhase {
        switch self {
        case .work: return .shortBreak
        case .shortBreak: return .work
        case .longBreak: return .work
        }
    }
}

struct PomodoroState {
    var currentPhase: PomodoroPhase = .work
    var timeRemaining: TimeInterval = PomodoroPhase.work.duration
    var sessionCount: Int = 0
    var isRunning: Bool = false
    var isPaused: Bool = false
    
    var progress: Double {
        let totalTime = currentPhase.duration
        return 1.0 - (timeRemaining / totalTime)
    }
    
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    mutating func start() {
        isRunning = true
        isPaused = false
    }
    
    mutating func pause() {
        isRunning = false
        isPaused = true
    }
    
    mutating func reset() {
        isRunning = false
        isPaused = false
        timeRemaining = currentPhase.duration
    }
    
    mutating func skip() {
        completePhase()
    }
    
    mutating func tick() {
        guard isRunning && timeRemaining > 0 else { return }
        timeRemaining -= 1
        
        // Don't auto-complete here - let the TimerViewModel handle completion
        // This prevents the race condition
    }
    
    // Check if phase should complete (for TimerViewModel to call)
    var shouldComplete: Bool {
        timeRemaining <= 0 && isRunning
    }
    
    private mutating func completePhase() {
        if currentPhase == .work {
            sessionCount += 1
        }
        
        // Every 4 work sessions, take a long break
        let nextPhase: PomodoroPhase
        if currentPhase == .work && (sessionCount + 1) % 4 == 0 {
            nextPhase = .longBreak
        } else {
            nextPhase = currentPhase.nextPhase
        }
        
        currentPhase = nextPhase
        timeRemaining = nextPhase.duration
        isRunning = false
        isPaused = false
    }
}
