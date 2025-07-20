import Foundation
import SwiftUI
import Combine

class TimerViewModel: ObservableObject {
    @Published var pomodoroState = PomodoroState()
    @Published var totalSessionsToday: Int = 0
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // UserDefaults keys
    private let sessionCountKey = "totalSessionsToday"
    private let lastSessionDateKey = "lastSessionDate"
    
    init() {
        loadPersistentData()
        setupNotificationObservers()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Timer Control
    
    func startTimer() {
        pomodoroState.start()
        startTimerLoop()
    }
    
    func pauseTimer() {
        pomodoroState.pause()
        stopTimerLoop()
    }
    
    func resetTimer() {
        pomodoroState.reset()
        stopTimerLoop()
    }
    
    func skipPhase() {
        print("⏭️ SKIP BUTTON PRESSED")
        let currentPhase = pomodoroState.currentPhase
        
        // Stop timer
        stopTimerLoop()
        
        // Increment totalSessionsToday only when skipping work
        if currentPhase == .work {
            totalSessionsToday += 1
            savePersistentData()
            print("✅ Work session skipped. Total today: \(totalSessionsToday)")
        }
        
        // Transition to next phase
        pomodoroState.skip()
        
        print("🔄 Skipped from \(currentPhase.rawValue) to \(pomodoroState.currentPhase.rawValue)")
    }
    
    // Debug function - set timer to 3 seconds for testing
    func setDebugTimer() {
        print("🐛 DEBUG: Setting timer to 3 seconds for testing")
        pomodoroState.timeRemaining = 3
    }
    
    // MARK: - Private Methods
    
    private func startTimerLoop() {
        stopTimerLoop() // Ensure no duplicate timers
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                // Check if phase should complete BEFORE ticking
                let shouldComplete = self?.pomodoroState.shouldComplete ?? false
                
                self?.pomodoroState.tick()
                
                // Debug: Show remaining time when close to completion
                if let timeRemaining = self?.pomodoroState.timeRemaining {
                    if timeRemaining <= 5 && timeRemaining > 0 {
                        print("⏰ Time remaining: \(timeRemaining)")
                    }
                }
                
                // Check if phase completed (using the flag from BEFORE tick)
                if shouldComplete {
                    print("⏰ PHASE SHOULD COMPLETE - calling handlePhaseComplete()")
                    self?.handlePhaseComplete()
                }
                
                // Play tick sound in last 10 seconds of work session
                if let timeRemaining = self?.pomodoroState.timeRemaining,
                   self?.pomodoroState.currentPhase == .work,
                   timeRemaining <= 10 && timeRemaining > 0 {
                    SoundManager.shared.playTimerTickSound()
                }
            }
        }
    }
    
    private func stopTimerLoop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handlePhaseComplete() {
        let completedPhase = pomodoroState.currentPhase
        
        print("🎯 PHASE COMPLETE: \(completedPhase.rawValue)")
        print("📊 Timer state - isRunning: \(pomodoroState.isRunning), timeRemaining: \(pomodoroState.timeRemaining)")
        
        // Update session count if work was completed
        if completedPhase == .work {
            totalSessionsToday += 1
            savePersistentData()
            print("✅ Work session completed. Total today: \(totalSessionsToday)")
        }
        
        // Stop timer
        stopTimerLoop()
        
        // Play sound for the completed phase
        print("🔊 About to play sound for: \(completedPhase.rawValue)")
        SoundManager.shared.playPhaseChangeSound(for: completedPhase)
        print("🔊 Sound call completed")
        
        // NOW complete the phase in the model (this changes state)
        print("🔄 Completing phase in model...")
        pomodoroState.skip() // This calls completePhase() internally
        print("🔄 Phase completion finished. New phase: \(pomodoroState.currentPhase.rawValue)")
        
        // Schedule notification
        NotificationManager.shared.schedulePhaseCompleteNotification(
            for: completedPhase,
            sessionCount: pomodoroState.sessionCount
        )
        
        print("📱 Phase complete handling finished")
    }
    
    // MARK: - Notification Handling
    
    private func setupNotificationObservers() {
        NotificationCenter.default.publisher(for: .startBreak)
            .sink { [weak self] _ in
                self?.startTimer()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .skipBreak)
            .sink { [weak self] _ in
                self?.skipPhase()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .startWork)
            .sink { [weak self] _ in
                self?.startTimer()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .skipWork)
            .sink { [weak self] _ in
                self?.skipPhase()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Persistence
    
    private func loadPersistentData() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastSessionDate = UserDefaults.standard.object(forKey: lastSessionDateKey) as? Date ?? Date.distantPast
        
        if Calendar.current.isDate(lastSessionDate, inSameDayAs: today) {
            totalSessionsToday = UserDefaults.standard.integer(forKey: sessionCountKey)
        } else {
            totalSessionsToday = 0
            savePersistentData() // Reset for new day
        }
    }
    
    private func savePersistentData() {
        UserDefaults.standard.set(totalSessionsToday, forKey: sessionCountKey)
        UserDefaults.standard.set(Date(), forKey: lastSessionDateKey)
    }
}