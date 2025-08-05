import Foundation
import AppKit

// MARK: - TimerController
// Specialized controller for timer logic and state management
// Handles: Timer loop, phase transitions, background activity

class TimerController {
    // MARK: - Delegate Communication
    weak var delegate: TimerControllerDelegate?
    
    // MARK: - Private Properties (Moved from TimerViewModel)
    private var timer: Timer?
    private var backgroundActivity: NSObjectProtocol?
    private var pomodoroState = PomodoroState()
    private var cachedSessionCount: Int = 0  // Cache to avoid reading persistent data every second
    
    // External integrations (injected dependencies)
    private var integrationController: IntegrationController?
    
    init() {
        // Initialize with current state
        // Note: Session count will be loaded by IntegrationController
    }
    
    deinit {
        timer?.invalidate()
        endBackgroundActivity()
    }
    
    // MARK: - Dependency Injection
    func setIntegrationController(_ controller: IntegrationController) {
        self.integrationController = controller
        // Load session count once when integration controller is set
        self.cachedSessionCount = controller.loadPersistentData()
    }
    
    // MARK: - Public Interface (Moved from TimerViewModel)
    
    func toggleTimer() {
        if pomodoroState.isRunning {
            Logger.debug("Calling pauseTimer()...", category: .timer)
            pauseTimer()
        } else {
            Logger.debug("Calling startTimer()...", category: .timer)
            startTimer()
        }
        Logger.debug("toggleTimer() completed - new state: isRunning=\(pomodoroState.isRunning)", category: .timer)
    }
    
    func startTimer() {
        Logger.timerState("Starting timer: \(pomodoroState.currentPhase.rawValue)")
        pomodoroState.start()
        beginBackgroundActivity()
        startTimerLoop()
        
        // Notify delegate of state change
        delegate?.timerDidUpdateState(pomodoroState)
        
        // Trigger external integrations
        integrationController?.scheduleStateFileWrite(immediate: true, pomodoroState: pomodoroState, sessionCount: getCurrentSessionCount())
        integrationController?.triggerSketchyBarEvent("pomodoro_start")
    }
    
    func pauseTimer() {
        Logger.timerState("Pausing timer: \(pomodoroState.currentPhase.rawValue)")
        pomodoroState.pause()
        endBackgroundActivity()
        stopTimerLoop()
        
        // Notify delegate of state change
        delegate?.timerDidUpdateState(pomodoroState)
        
        // Trigger external integrations
        integrationController?.scheduleStateFileWrite(immediate: true, pomodoroState: pomodoroState, sessionCount: getCurrentSessionCount())
        integrationController?.triggerSketchyBarEvent("pomodoro_stop")
    }
    
    func resetTimer() {
        Logger.timerState("Resetting timer: \(pomodoroState.currentPhase.rawValue)")
        pomodoroState.reset()
        endBackgroundActivity()
        stopTimerLoop()
        
        // Notify delegate of state change
        delegate?.timerDidUpdateState(pomodoroState)
        
        // Trigger external integrations
        integrationController?.scheduleStateFileWrite(immediate: true, pomodoroState: pomodoroState, sessionCount: getCurrentSessionCount())
        integrationController?.triggerSketchyBarEvent("pomodoro_stop")
    }
    
    func skipPhase() {
        Logger.timerState("Skipping phase: \(pomodoroState.currentPhase.rawValue)")
        let wasWork = pomodoroState.currentPhase == .work
        
        endBackgroundActivity()
        stopTimerLoop()
        
        // Update session count if completing work phase
        if wasWork {
            incrementSessionCount()
        }
        
        pomodoroState.skip()
        
        // Notify delegate of state change
        delegate?.timerDidUpdateState(pomodoroState)
        
        // Trigger external integrations
        integrationController?.scheduleStateFileWrite(immediate: true, pomodoroState: pomodoroState, sessionCount: getCurrentSessionCount())
        
        Logger.timerState("Skipped to: \(pomodoroState.currentPhase.rawValue)")
    }
    
    // MARK: - Timer Loop Management (Moved from TimerViewModel)
    
    private func startTimerLoop() {
        timer?.invalidate()
        
        // Ensure timer creation happens on main thread for menu bar apps
        DispatchQueue.main.async { [weak self] in
            self?.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.handleTimerTick()
                }
            }
            
            // Add timer to run loop with common modes for background operation
            if let timer = self?.timer {
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }
    
    private func stopTimerLoop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleTimerTick() {
        let shouldComplete = pomodoroState.shouldComplete
        pomodoroState.tick()
        
        // Notify delegate of state change
        delegate?.timerDidUpdateState(pomodoroState)
        
        // Smart interval file writing
        integrationController?.scheduleStateFileWrite(immediate: false, pomodoroState: pomodoroState, sessionCount: getCurrentSessionCount())
        
        if shouldComplete {
            handlePhaseComplete()
        }
    }
    
    private func handlePhaseComplete() {
        let completedPhase = pomodoroState.currentPhase
        
        // Update session count if completing work phase
        if completedPhase == .work {
            incrementSessionCount()
            Logger.timerState("Work session completed. Total today: \(cachedSessionCount)")
        }
        
        endBackgroundActivity()
        stopTimerLoop()
        
        // Play completion sound
        SoundManager.shared.playPhaseChangeSound(for: completedPhase)
        
        // Complete the phase (transition to next)
        pomodoroState.skip()
        
        // Notify delegate of state change
        delegate?.timerDidUpdateState(pomodoroState)
        
        // Trigger external integrations
        integrationController?.scheduleStateFileWrite(immediate: true, pomodoroState: pomodoroState, sessionCount: getCurrentSessionCount())
        
        // Schedule notification
        NotificationManager.shared.schedulePhaseCompleteNotification(
            for: completedPhase,
            sessionCount: getCurrentSessionCount()
        )
        
        Logger.timerState("Phase completed. New phase: \(pomodoroState.currentPhase.rawValue)")
    }
    
    // MARK: - Background Activity Management (Moved from TimerViewModel)
    
    private func beginBackgroundActivity() {
        guard backgroundActivity == nil else { return }
        
        backgroundActivity = ProcessInfo.processInfo.beginActivity(
            options: [.background, .idleSystemSleepDisabled],
            reason: "Pomodoro timer running"
        )
        Logger.debug("🔋 Started background activity - preventing App Nap while timer runs", category: .app)
    }
    
    private func endBackgroundActivity() {
        if let activity = backgroundActivity {
            ProcessInfo.processInfo.endActivity(activity)
            backgroundActivity = nil
            Logger.debug("🔋 Ended background activity - allowing App Nap while timer idle", category: .app)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentSessionCount() -> Int {
        return cachedSessionCount
    }
    
    private func incrementSessionCount() {
        cachedSessionCount += 1
        // Update persistent storage
        integrationController?.savePersistentData(sessionCount: cachedSessionCount)
        // Notify delegate
        delegate?.timerDidUpdateSessionCount(cachedSessionCount)
    }
}