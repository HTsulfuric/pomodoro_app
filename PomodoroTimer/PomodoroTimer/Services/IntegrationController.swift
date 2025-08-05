import Combine
import Foundation

// MARK: - IntegrationController

// Specialized controller for external integrations and I/O
// Handles: SketchyBar integration, file I/O, notifications, persistence

class IntegrationController {
    // MARK: - Delegate Communication

    weak var delegate: IntegrationControllerDelegate?

    // MARK: - Private Properties (Moved from TimerViewModel)

    private var sketchyBarConfig: SketchyBarConfig = .load()
    private var lastStateWrite: Date = .distantPast
    private var cancellables = Set<AnyCancellable>()

    private var stateFileURL: URL {
        let expandedPath = NSString(string: sketchyBarConfig.stateFilePath).expandingTildeInPath
        return URL(fileURLWithPath: expandedPath)
    }

    init() {
        createStateFileDirectory()
        setupNotificationObservers()
        setupConfigObserver()

        // Write initial state file
        scheduleStateFileWrite(immediate: true, pomodoroState: PomodoroState(), sessionCount: loadPersistentData())
    }

    deinit {
        // Combine cancellables are automatically cleaned up
    }

    // MARK: - Private Setup Methods (Moved from TimerViewModel)

    private func createStateFileDirectory() {
        let directory = stateFileURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    private func setupNotificationObservers() {
        // Regular notification center observers (for user notification actions)
        NotificationCenter.default.publisher(for: .startBreak)
            .sink { _ in
                // Notify coordinator that timer should start
                // This will be handled by the coordinator calling TimerController
                // For now, we just log
                Logger.debug("Notification: Start break requested", category: .notifications)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .skipBreak)
            .sink { _ in
                Logger.debug("Notification: Skip break requested", category: .notifications)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .startWork)
            .sink { _ in
                Logger.debug("Notification: Start work requested", category: .notifications)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .skipWork)
            .sink { _ in
                Logger.debug("Notification: Skip work requested", category: .notifications)
            }
            .store(in: &cancellables)

        Logger.debug("IntegrationController listening for user notification actions", category: .notifications)
    }

    private func setupConfigObserver() {
        // Listen for SketchyBar configuration changes
        NotificationCenter.default.publisher(for: .sketchyBarConfigChanged)
            .sink { [weak self] notification in
                if let config = notification.object as? SketchyBarConfig {
                    self?.sketchyBarConfig = config
                    Logger.debug("SketchyBar configuration updated", category: .app)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Interface (Moved from TimerViewModel)

    func scheduleStateFileWrite(immediate: Bool, pomodoroState: PomodoroState, sessionCount: Int) {
        // Skip all SketchyBar I/O if disabled
        guard sketchyBarConfig.isEnabled else {
            return
        }

        if immediate {
            // Immediate writes for state changes (start/pause/complete/skip)
            writeStateFile(pomodoroState: pomodoroState, sessionCount: sessionCount)
            return
        }

        // Only write if enough time has passed
        let timeSinceLastWrite = Date().timeIntervalSince(lastStateWrite)

        if timeSinceLastWrite >= sketchyBarConfig.updateInterval {
            writeStateFile(pomodoroState: pomodoroState, sessionCount: sessionCount)
        }
        // Skip write if interval hasn't elapsed - reduces I/O based on configuration
    }

    func triggerSketchyBarEvent(_ event: String) {
        // Skip all SketchyBar I/O if disabled
        guard sketchyBarConfig.isEnabled else {
            return
        }

        // Validate event parameter against allowlist to prevent command injection
        let allowedEvents: Set<String> = ["pomodoro_start", "pomodoro_stop"]
        guard allowedEvents.contains(event) else {
            Logger.debug("Blocked invalid SketchyBar event: \(event)", category: .app)
            return
        }

        // Asynchronous process execution to prevent UI blocking (optimized for infrequent usage)
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self else { return }

            let process = Process()
            process.executableURL = URL(fileURLWithPath: sketchyBarConfig.sketchyBarPath)
            process.arguments = ["--trigger", event]

            do {
                try process.run()
                process.waitUntilExit()

                if process.terminationStatus == 0 {
                    Logger.debug("SketchyBar event triggered: \(event)", category: .app)
                } else {
                    Logger.warning("SketchyBar event '\(event)' failed with exit code: \(process.terminationStatus)", category: .app)
                }
            } catch {
                Logger.warning("Failed to trigger SketchyBar event '\(event)': \(error.localizedDescription)", category: .app)
            }
        }
    }

    func loadPersistentData() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let lastSessionDate = UserDefaults.standard.object(forKey: "lastSessionDate") as? Date ?? Date.distantPast

        if Calendar.current.isDate(lastSessionDate, inSameDayAs: today) {
            let sessionCount = UserDefaults.standard.integer(forKey: "totalSessionsToday")
            Logger.info("📊 Loaded persistent data: \(sessionCount) sessions today", category: .app)
            return sessionCount
        } else {
            savePersistentData(sessionCount: 0)
            Logger.info("📊 New day - resetting session count to 0", category: .app)
            return 0
        }
    }

    func savePersistentData(sessionCount: Int) {
        UserDefaults.standard.set(sessionCount, forKey: "totalSessionsToday")
        UserDefaults.standard.set(Date(), forKey: "lastSessionDate")
    }

    // MARK: - Private Helper Methods (Moved from TimerViewModel)

    private func writeStateFile(pomodoroState: PomodoroState, sessionCount: Int) {
        let currentTime = Date()
        let stateData: [String: Any] = [
            "appPid": ProcessInfo.processInfo.processIdentifier,
            "phase": pomodoroState.currentPhase.rawValue,
            "timeRemaining": Int(pomodoroState.timeRemaining),
            "progressPercent": pomodoroState.progress * 100.0,
            "totalDuration": Int(pomodoroState.currentPhase.duration),
            "sessionCount": sessionCount,
            "isRunning": pomodoroState.isRunning,
            "lastUpdateTimestamp": currentTime.timeIntervalSince1970,
        ]

        // Update last write time for smart interval tracking
        lastStateWrite = currentTime

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: stateData, options: [.prettyPrinted])
            try jsonData.write(to: stateFileURL)
            Logger.debug("📄 JSON state file updated immediately", category: .app)
        } catch {
            Logger.error("Failed to write state file", category: .app, error: error)
        }
    }
}
