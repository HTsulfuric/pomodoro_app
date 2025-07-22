import Foundation
import AudioToolbox

/// Shared timer state singleton - single source of truth across all XPC connections
class SharedTimerState {
    static let shared = SharedTimerState()
    
    var pomodoroState = PomodoroState()
    var totalSessionsToday: Int = 0
    var timer: Timer?
    
    // Track multiple client connections for UI updates using weak references
    private var clientConnections: [WeakConnectionWrapper] = []
    
    // Weak wrapper to prevent retain cycles
    private class WeakConnectionWrapper {
        weak var connection: NSXPCConnection?
        
        init(_ connection: NSXPCConnection) {
            self.connection = connection
        }
    }
    
    // MARK: - SketchyBar Integration
    let stateManager = StateManager.shared
    
    // Cache SketchyBar executable path to avoid repeated file system checks
    private static var cachedSketchyBarPath: String?
    private static let sketchyBarPathLock = NSLock()
    
    // Rate limiting for SketchyBar updates
    private var lastSketchyBarUpdate: Date = Date.distantPast
    private let sketchyBarUpdateInterval: TimeInterval = 0.5 // Update max every 500ms
    
    // Rate limiting for file I/O operations
    private var lastPersistentDataSave: Date = Date.distantPast
    private let persistentDataSaveInterval: TimeInterval = 5.0 // Save max every 5 seconds
    private var pendingPersistentDataSave: Bool = false
    
    private var lastStateManagerWrite: Date = Date.distantPast
    private let stateManagerWriteInterval: TimeInterval = 1.0 // Write max every 1 second
    
    private init() {
        loadPersistentData()
        print("🚀 SharedTimerState initialized with \(totalSessionsToday) sessions today")
    }
    
    func addClientConnection(_ connection: NSXPCConnection) {
        // Clean up any dead connections first
        cleanupDeadConnections()
        
        clientConnections.append(WeakConnectionWrapper(connection))
        print("🔗 Added client connection. Total: \(clientConnections.count)")
    }
    
    func removeClientConnection(_ connection: NSXPCConnection) {
        clientConnections.removeAll { wrapper in
            wrapper.connection == nil || wrapper.connection === connection
        }
        print("🔗 Removed client connection. Total: \(clientConnections.count)")
    }
    
    private func cleanupDeadConnections() {
        let beforeCount = clientConnections.count
        clientConnections.removeAll { $0.connection == nil }
        let afterCount = clientConnections.count
        
        if beforeCount != afterCount {
            print("🧹 Cleaned up \(beforeCount - afterCount) dead connections")
        }
    }
    
    func notifyAllClients() {
        // Clean up dead connections first
        cleanupDeadConnections()
        
        // Send simple state using basic Foundation types
        let phase = pomodoroState.currentPhase.rawValue
        let timeRemaining = pomodoroState.timeRemaining
        let sessionCount = totalSessionsToday
        let isRunning = pomodoroState.isRunning
        let isPaused = pomodoroState.isPaused
        
        var notifiedCount = 0
        
        // Notify all live connections without blocking
        for wrapper in clientConnections {
            guard let connection = wrapper.connection else { continue }
            
            // Use async proxy to avoid blocking on dead connections
            if let proxy = connection.remoteObjectProxyWithErrorHandler({ error in
                print("⚠️ Failed to notify client: \(error.localizedDescription)")
            }) as? PomodoroClientProtocol {
                
                // Notify asynchronously to prevent blocking
                DispatchQueue.global(qos: .utility).async {
                    proxy.pomodoroStateDidChange(
                        phase: phase,
                        timeRemaining: timeRemaining,
                        sessionCount: sessionCount,
                        isRunning: isRunning,
                        isPaused: isPaused
                    )
                }
                notifiedCount += 1
            }
        }
        
        print("📤 Notified \(notifiedCount) UI clients of state change")
    }
    
    private func loadPersistentData() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastSessionDate = UserDefaults.standard.object(forKey: "lastSessionDate") as? Date ?? Date.distantPast
        
        if Calendar.current.isDate(lastSessionDate, inSameDayAs: today) {
            totalSessionsToday = UserDefaults.standard.integer(forKey: "totalSessionsToday")
        } else {
            totalSessionsToday = 0
            savePersistentData()
        }
    }
    
    func savePersistentData() {
        savePersistentDataWithRateLimit(force: false)
    }
    
    private func savePersistentDataWithRateLimit(force: Bool) {
        let now = Date()
        
        if force || now.timeIntervalSince(lastPersistentDataSave) >= persistentDataSaveInterval {
            // Actually save to disk
            UserDefaults.standard.set(totalSessionsToday, forKey: "totalSessionsToday")
            UserDefaults.standard.set(Date(), forKey: "lastSessionDate")
            lastPersistentDataSave = now
            pendingPersistentDataSave = false
            print("💾 Persistent data saved to disk")
        } else {
            // Mark as pending for later save
            pendingPersistentDataSave = true
            
            // Schedule a delayed save if not already scheduled
            DispatchQueue.main.asyncAfter(deadline: .now() + persistentDataSaveInterval) { [weak self] in
                guard let self = self else { return }
                if self.pendingPersistentDataSave {
                    self.savePersistentDataWithRateLimit(force: true)
                }
            }
        }
    }
}

/// XPC Service implementation that manages the Pomodoro timer as the single source of truth
class TimerService: NSObject, PomodoroServiceProtocol {
    
    // MARK: - Shared State Reference
    
    private let sharedState = SharedTimerState.shared
    
    // MARK: - Connection Management
    
    private weak var connection: NSXPCConnection?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        print("🎯 TimerService instance created")
    }
    
    // MARK: - XPC Connection Management
    
    /// Set the client connection for bidirectional communication
    func setClientConnection(_ connection: NSXPCConnection) {
        self.connection = connection
        
        // Register this connection for state updates
        sharedState.addClientConnection(connection)
        
        print("🔗 Client connection established and registered")
    }
    
    // MARK: - PomodoroServiceProtocol Implementation
    
    func toggleTimer(reply: @escaping (Bool) -> Void) {
        print("📥 XPC Command: toggleTimer")
        
        if sharedState.pomodoroState.isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
        
        // Notify all clients of state change
        sharedState.notifyAllClients()
        reply(true)
    }
    
    func resetTimer(reply: @escaping (Bool) -> Void) {
        print("📥 XPC Command: resetTimer")
        
        sharedState.pomodoroState.reset()
        stopTimerLoop()
        
        // Notify all clients of state change
        sharedState.notifyAllClients()
        reply(true)
    }
    
    func skipPhase(reply: @escaping (Bool) -> Void) {
        print("📥 XPC Command: skipPhase")
        
        let currentPhase = sharedState.pomodoroState.currentPhase
        
        // Stop timer
        stopTimerLoop()
        
        // Increment totalSessionsToday only when skipping work
        if currentPhase == .work {
            sharedState.totalSessionsToday += 1
            sharedState.savePersistentData()
            print("✅ Work session skipped. Total today: \(sharedState.totalSessionsToday)")
        }
        
        // Transition to next phase
        sharedState.pomodoroState.skip()
        
        // Notify all clients of state change
        sharedState.notifyAllClients()
        
        print("🔄 Skipped from \(currentPhase.rawValue) to \(sharedState.pomodoroState.currentPhase.rawValue)")
        reply(true)
    }
    
    func getCurrentState(reply: @escaping (Bool) -> Void) {
        // Simply return true to indicate service is responsive
        reply(true)
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        sharedState.pomodoroState.start()
        startTimerLoop()
        print("▶️ Timer started: \(sharedState.pomodoroState.currentPhase.rawValue)")
    }
    
    private func pauseTimer() {
        sharedState.pomodoroState.pause()
        stopTimerLoop()
        print("⏸️ Timer paused: \(sharedState.pomodoroState.currentPhase.rawValue)")
    }
    
    private func startTimerLoop() {
        print("🔄 Starting timer loop in XPC service")
        
        // Check if already on main thread to avoid unnecessary dispatch
        if Thread.isMainThread {
            createTimerOnMainThread()
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.createTimerOnMainThread()
            }
        }
    }
    
    private func createTimerOnMainThread() {
        // Stop any existing timer (synchronously on main thread)
        sharedState.timer?.invalidate()
        sharedState.timer = nil
        
        print("🎯 Creating timer on main thread")
        
        sharedState.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            // Timer already runs on main thread, no need for additional dispatch
            self?.handleTimerTick()
        }
        
        print("✅ Timer created and scheduled on main RunLoop")
    }
    
    private func stopTimerLoop() {
        // Use sync dispatch to ensure timer is stopped immediately
        if Thread.isMainThread {
            sharedState.timer?.invalidate()
            sharedState.timer = nil
            print("🛑 Timer stopped on main thread")
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.sharedState.timer?.invalidate()
                self?.sharedState.timer = nil
                print("🛑 Timer stopped on main thread")
            }
        }
    }
    
    private func handleTimerTick() {
        // Check if phase should complete BEFORE ticking
        let shouldComplete = sharedState.pomodoroState.shouldComplete
        
        sharedState.pomodoroState.tick()
        
        // Debug: Show tick info every 10 seconds
        let timeRemaining = Int(sharedState.pomodoroState.timeRemaining)
        if timeRemaining % 10 == 0 {
            print("⏰ Timer tick: \(timeRemaining)s remaining")
        }
        
        // Notify all clients of state change
        sharedState.notifyAllClients()
        
        // Update SketchyBar state
        updateSketchyBarState()
        
        // Play tick sound in last 10 seconds of work session
        if sharedState.pomodoroState.timeRemaining <= 10 && sharedState.pomodoroState.timeRemaining > 0 && sharedState.pomodoroState.currentPhase == .work {
            playTickSound()
        }
        
        // Check if phase completed (using the flag from BEFORE tick)
        if shouldComplete {
            print("⏰ PHASE COMPLETE - handling phase completion")
            handlePhaseComplete()
        }
    }
    
    private func handlePhaseComplete() {
        let completedPhase = sharedState.pomodoroState.currentPhase
        
        print("🎯 PHASE COMPLETE: \(completedPhase.rawValue)")
        
        // Update session count if work was completed
        if completedPhase == .work {
            sharedState.totalSessionsToday += 1
            sharedState.savePersistentData()
            print("✅ Work session completed. Total today: \(sharedState.totalSessionsToday)")
        }
        
        // Stop timer
        stopTimerLoop()
        
        // Play completion sound
        playPhaseCompletionSound(for: completedPhase)
        
        // Complete the phase (transition to next)
        sharedState.pomodoroState.skip()
        print("🔄 Phase completed. New phase: \(sharedState.pomodoroState.currentPhase.rawValue)")
        
        // Notify all clients of state change
        sharedState.notifyAllClients()
        
        // Update SketchyBar with new state
        updateSketchyBarState()
        
        print("📱 Phase completion handling finished")
    }
    
    // MARK: - SketchyBar Integration
    
    private func updateSketchyBarState() {
        let timerState = TimerState(from: sharedState.pomodoroState, sessionCount: sharedState.totalSessionsToday)
        
        // Rate limit state manager writes to reduce file I/O
        let now = Date()
        if now.timeIntervalSince(sharedState.lastStateManagerWrite) >= sharedState.stateManagerWriteInterval {
            sharedState.stateManager.writeState(timerState)
            sharedState.lastStateManagerWrite = now
        }
        
        // Rate limit SketchyBar updates to prevent excessive process creation
        if now.timeIntervalSince(sharedState.lastSketchyBarUpdate) >= sharedState.sketchyBarUpdateInterval {
            sharedState.lastSketchyBarUpdate = now
            executeSketchyBarUpdate(timerState)
        }
    }
    
    private func executeSketchyBarUpdate(_ state: TimerState) {
        // Get cached SketchyBar path or find it
        guard let sketchybarPath = getSketchyBarPath() else {
            return // SketchyBar not found, skip update
        }
        
        // Format time as MM:SS
        let minutes = state.timeRemaining / 60
        let seconds = state.timeRemaining % 60
        let timeLabel = String(format: "%02d:%02d", minutes, seconds)
        
        // Choose icon and color based on phase and running state
        let (icon, color): (String, String)
        
        switch state.phase {
        case "Work Session":
            icon = "􀐱"  // Timer icon
            color = state.isRunning ? "0xffa3be8c" : "0xff7f8490"  // Green when running, gray when paused
        case "Short Break":
            icon = "􀁰"  // Break icon
            color = state.isRunning ? "0xffebcb8b" : "0xff7f8490"  // Yellow when running, gray when paused
        case "Long Break":
            icon = "􀁰"  // Break icon
            color = state.isRunning ? "0xffd08770" : "0xff7f8490"  // Orange when running, gray when paused
        default:
            icon = "􀐱"
            color = "0xff7f8490"  // Default gray
        }
        
        // Execute SketchyBar command in background with proper cleanup
        DispatchQueue.global(qos: .utility).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: sketchybarPath)
            process.arguments = [
                "--set", "pomodoro_item",
                "label=\(timeLabel)",
                "icon=\(icon)",
                "icon.color=\(color)"
            ]
            
            // Set up timeout handling
            let timeoutTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                if process.isRunning {
                    process.terminate()
                }
            }
            
            do {
                try process.run()
                process.waitUntilExit()
                timeoutTimer.invalidate()
            } catch {
                timeoutTimer.invalidate()
                // Silently ignore SketchyBar errors to avoid spamming logs
            }
        }
    }
    
    private func getSketchyBarPath() -> String? {
        SharedTimerState.sketchyBarPathLock.lock()
        defer { SharedTimerState.sketchyBarPathLock.unlock() }
        
        // Return cached path if available
        if let cached = SharedTimerState.cachedSketchyBarPath {
            return cached
        }
        
        // Search for SketchyBar executable
        let possiblePaths = [
            "/opt/homebrew/bin/sketchybar",
            "/usr/local/bin/sketchybar",
            "/usr/bin/sketchybar"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                SharedTimerState.cachedSketchyBarPath = path
                return path
            }
        }
        
        return nil
    }
    
    // MARK: - Audio Management
    
    private func playTickSound() {
        AudioServicesPlaySystemSound(1103) // Tink sound
    }
    
    private func playPhaseCompletionSound(for phase: PomodoroPhase) {
        // Use different sounds for different phase completions
        let soundID: SystemSoundID
        switch phase {
        case .work:
            soundID = 1012 // Work completed - positive sound
        case .shortBreak, .longBreak:
            soundID = 1016 // Break completed - gentle sound
        }
        
        AudioServicesPlaySystemSound(soundID)
    }
}

// MARK: - XPC Service Entry Point

class TimerServiceDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        print("🔌 New XPC connection request from PID: \(newConnection.processIdentifier)")
        
        // Configure the connection
        newConnection.exportedInterface = NSXPCInterface(with: PomodoroServiceProtocol.self)
        
        // Create new TimerService instance for this connection
        let timerService = TimerService()
        timerService.setClientConnection(newConnection)
        newConnection.exportedObject = timerService
        
        // Configure client interface for bidirectional communication
        newConnection.remoteObjectInterface = NSXPCInterface(with: PomodoroClientProtocol.self)
        
        // Handle connection lifecycle with shared state cleanup
        newConnection.invalidationHandler = {
            print("❌ XPC connection invalidated - removing from shared state")
            SharedTimerState.shared.removeClientConnection(newConnection)
        }
        
        newConnection.interruptionHandler = {
            print("⚠️ XPC connection interrupted")
        }
        
        newConnection.resume()
        print("✅ XPC connection established and resumed")
        
        return true
    }
}