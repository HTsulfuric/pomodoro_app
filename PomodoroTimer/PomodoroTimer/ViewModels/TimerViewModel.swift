import Foundation
import SwiftUI
import Combine
import AppKit

class TimerViewModel: ObservableObject {
    @Published var pomodoroState = PomodoroState()
    @Published var totalSessionsToday: Int = 0
    @Published var currentTheme: AnyTheme = ThemeRegistry.shared.defaultTheme ?? AnyTheme(MinimalTheme())
    
    // Theme picker state management
    @Published var isThemePickerPresented: Bool = false
    @Published var highlightedTheme: AnyTheme?
    @Published var highlightedThemeIndex: Int = 0
    private var originalTheme: AnyTheme?
    
    // Timer management
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // Debounced state file writing to prevent I/O storms
    private let stateWriteSubject = PassthroughSubject<Bool, Never>()
    
    // Background activity management to prevent App Nap
    private var backgroundActivity: NSObjectProtocol?
    
    // State file management for SketchyBar
    private let stateFileURL: URL = {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let configDir = homeDir.appendingPathComponent(".config/pomodoro-timer")
        return configDir.appendingPathComponent("state.json")
    }()
    
    init() {
        loadPersistentData()
        loadTheme()
        setupNotificationObservers()
        setupDebouncedStateFileWriter()
        createStateFileDirectory()
        scheduleStateFileWrite(immediate: true)
    }
    
    deinit {
        timer?.invalidate()
        endBackgroundActivity()
        // Combine cancellables are automatically cleaned up
    }
    
    private func createStateFileDirectory() {
        let directory = stateFileURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
    
    // MARK: - Debounced State File Writing
    
    /// Setup debounced state file writer to prevent I/O storms
    /// Critical fix: Was writing to disk every second, now max once per 5 seconds
    private func setupDebouncedStateFileWriter() {
        stateWriteSubject
            .debounce(for: .seconds(5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.writeStateFile()
            }
            .store(in: &cancellables)
    }
    
    /// Schedule a state file write - immediate for critical changes, debounced for routine updates
    /// - Parameter immediate: If true, writes immediately. If false, debounces to max once per 5 seconds
    private func scheduleStateFileWrite(immediate: Bool) {
        if immediate {
            writeStateFile()
        } else {
            stateWriteSubject.send(true)
        }
    }
    
    // MARK: - Background Activity Management
    
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
    
    // MARK: - Timer Control
    
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
        beginBackgroundActivity()  // Prevent App Nap while timer runs
        startTimerLoop()
        scheduleStateFileWrite(immediate: true)
        
        // Signal SketchyBar to begin monitoring
        triggerSketchyBarEvent("pomodoro_start")
    }
    
    func pauseTimer() {
        Logger.timerState("Pausing timer: \(pomodoroState.currentPhase.rawValue)")
        pomodoroState.pause()
        endBackgroundActivity()  // Allow App Nap when timer paused
        stopTimerLoop()
        scheduleStateFileWrite(immediate: true)
        
        // Signal SketchyBar to stop monitoring
        triggerSketchyBarEvent("pomodoro_stop")
    }
    
    func resetTimer() {
        Logger.timerState("Resetting timer: \(pomodoroState.currentPhase.rawValue)")
        pomodoroState.reset()
        endBackgroundActivity()  // Allow App Nap when timer reset
        stopTimerLoop()
        scheduleStateFileWrite(immediate: true)
        
        // Signal SketchyBar to stop monitoring
        triggerSketchyBarEvent("pomodoro_stop")
    }
    
    func skipPhase() {
        Logger.timerState("Skipping phase: \(pomodoroState.currentPhase.rawValue)")
        let wasWork = pomodoroState.currentPhase == .work
        
        endBackgroundActivity()  // Allow App Nap when phase skipped
        stopTimerLoop()
        
        if wasWork {
            totalSessionsToday += 1
            savePersistentData()
        }
        
        pomodoroState.skip()
        scheduleStateFileWrite(immediate: true)
        
        Logger.timerState("Skipped to: \(pomodoroState.currentPhase.rawValue)")
    }
    
    // MARK: - Timer Loop Management
    
    private func startTimerLoop() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.handleTimerTick()
        }
    }
    
    private func stopTimerLoop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleTimerTick() {
        let shouldComplete = pomodoroState.shouldComplete
        pomodoroState.tick()
        
        // Only schedule debounced state write during tick
        scheduleStateFileWrite(immediate: false)
        
        if shouldComplete {
            handlePhaseComplete()
        }
    }
    
    private func handlePhaseComplete() {
        let completedPhase = pomodoroState.currentPhase
        
        if completedPhase == .work {
            totalSessionsToday += 1
            savePersistentData()
            Logger.timerState("Work session completed. Total today: \(totalSessionsToday)")
        }
        
        endBackgroundActivity()  // Allow App Nap when phase completes
        stopTimerLoop()
        
        // Play completion sound
        SoundManager.shared.playPhaseChangeSound(for: completedPhase)
        
        // Complete the phase (transition to next)
        pomodoroState.skip()
        scheduleStateFileWrite(immediate: true)
        
        // Schedule notification
        NotificationManager.shared.schedulePhaseCompleteNotification(
            for: completedPhase,
            sessionCount: totalSessionsToday
        )
        
        Logger.timerState("Phase completed. New phase: \(pomodoroState.currentPhase.rawValue)")
    }
    
    // MARK: - Theme Management
    
    func setTheme(_ newTheme: AnyTheme) {
        currentTheme = newTheme
        UserDefaults.standard.set(newTheme.id, forKey: "selectedTheme")
        
        // Request window resize for the new theme
        // Note: Window resize removed - all themes now use full screen
    }
    
    private func loadTheme() {
        if let savedThemeId = UserDefaults.standard.string(forKey: "selectedTheme"),
           let savedTheme = ThemeRegistry.shared.theme(withId: savedThemeId) {
            currentTheme = savedTheme
        } else {
            // Use default theme from registry or fallback to minimal
            if let defaultTheme = ThemeRegistry.shared.defaultTheme {
                currentTheme = defaultTheme
            } else {
            }
        }
        
        // Note: Window resize will be handled by AppDelegate after setup is complete
    }
    
    // MARK: - Theme Picker Management
    
    func toggleThemePicker() {
        if isThemePickerPresented {
            cancelThemeSelection()
        } else {
            presentThemePicker()
        }
    }
    
    func presentThemePicker() {
        originalTheme = currentTheme
        isThemePickerPresented = true
        
        // Initialize highlighted theme to current theme
        if let currentIndex = ThemeRegistry.shared.availableThemes.firstIndex(where: { $0.id == currentTheme.id }) {
            setHighlightedThemeIndex(currentIndex)
        }
    }
    
    func selectNextTheme() {
        let themes = ThemeRegistry.shared.availableThemes
        guard !themes.isEmpty else { return }
        
        highlightedThemeIndex = (highlightedThemeIndex + 1) % themes.count
        updateHighlightedTheme()
    }
    
    func selectPreviousTheme() {
        let themes = ThemeRegistry.shared.availableThemes
        guard !themes.isEmpty else { return }
        
        highlightedThemeIndex = highlightedThemeIndex > 0 ? highlightedThemeIndex - 1 : themes.count - 1
        updateHighlightedTheme()
    }
    
    func setHighlightedThemeIndex(_ index: Int) {
        let themes = ThemeRegistry.shared.availableThemes
        guard index >= 0 && index < themes.count else { return }
        
        highlightedThemeIndex = index
        updateHighlightedTheme()
    }
    
    private func updateHighlightedTheme() {
        let themes = ThemeRegistry.shared.availableThemes
        guard highlightedThemeIndex >= 0 && highlightedThemeIndex < themes.count else { return }
        
        highlightedTheme = themes[highlightedThemeIndex]
        
        // Apply live preview
        currentTheme = highlightedTheme!
    }
    
    func confirmThemeSelection() {
        if let highlightedTheme = highlightedTheme {
            setTheme(highlightedTheme)
        }
        isThemePickerPresented = false
        originalTheme = nil
    }
    
    func cancelThemeSelection() {
        if let originalTheme = originalTheme {
            currentTheme = originalTheme
        }
        isThemePickerPresented = false
        highlightedTheme = nil
        self.originalTheme = nil
    }
    
    // MARK: - State File Management for SketchyBar
    
    private func writeStateFile() {
        let stateData: [String: Any] = [
            "appPid": ProcessInfo.processInfo.processIdentifier,
            "phase": pomodoroState.currentPhase.rawValue,
            "timeRemaining": Int(pomodoroState.timeRemaining),
            "sessionCount": totalSessionsToday,
            "isRunning": pomodoroState.isRunning,
            "lastUpdateTimestamp": Date().timeIntervalSince1970
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: stateData, options: [.prettyPrinted])
            try jsonData.write(to: stateFileURL)
        } catch {
            Logger.error("Failed to write state file", category: .app, error: error)
        }
    }
    
    // MARK: - SketchyBar Integration
    
    private func triggerSketchyBarEvent(_ event: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/sketchybar")
        process.arguments = ["--trigger", event]
        
        do {
            try process.run()
            Logger.debug("SketchyBar event triggered: \(event)", category: .app)
        } catch {
            Logger.warning("Failed to trigger SketchyBar event '\(event)': \(error.localizedDescription)", category: .app)
        }
    }
    
    // MARK: - Persistent Data Management
    
    private func loadPersistentData() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastSessionDate = UserDefaults.standard.object(forKey: "lastSessionDate") as? Date ?? Date.distantPast
        
        if Calendar.current.isDate(lastSessionDate, inSameDayAs: today) {
            totalSessionsToday = UserDefaults.standard.integer(forKey: "totalSessionsToday")
        } else {
            totalSessionsToday = 0
            savePersistentData()
        }
        
        Logger.info("📊 Loaded persistent data: \(totalSessionsToday) sessions today", category: .app)
    }
    
    private func savePersistentData() {
        UserDefaults.standard.set(totalSessionsToday, forKey: "totalSessionsToday")
        UserDefaults.standard.set(Date(), forKey: "lastSessionDate")
    }
    
    // MARK: - Notification Handling
    
    private func setupNotificationObservers() {
        // Regular notification center observers (for user notification actions)
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
        
        Logger.debug("TimerViewModel listening for user notification actions", category: .notifications)
    }
}
