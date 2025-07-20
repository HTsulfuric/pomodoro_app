import Foundation

/// Represents the shared state consumable by SketchyBar and external systems
struct TimerState: Codable, Equatable {
    let appPid: Int32
    let phase: String
    let timeRemaining: Int
    let sessionCount: Int
    let isRunning: Bool
    let lastUpdateTimestamp: TimeInterval
    
    /// Create TimerState from PomodoroState
    init(from pomodoroState: PomodoroState, sessionCount: Int) {
        self.appPid = ProcessInfo.processInfo.processIdentifier
        self.phase = pomodoroState.currentPhase.rawValue
        self.timeRemaining = Int(pomodoroState.timeRemaining)
        self.sessionCount = sessionCount
        self.isRunning = pomodoroState.isRunning
        self.lastUpdateTimestamp = Date().timeIntervalSince1970
    }
}

/// Thread-safe, atomic persistence manager for timer state
/// Manages shared JSON state file for SketchyBar integration
class StateManager {
    static let shared = StateManager()
    
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.pomodorotimer.statemanager", qos: .utility)
    
    private init() {
        // Create Application Support directory structure
        // Use shared location that SketchyBar can access (not sandboxed)
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let pomodoroDir = homeDir.appendingPathComponent(".config/pomodoro-timer")
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: pomodoroDir.path) {
            do {
                try FileManager.default.createDirectory(at: pomodoroDir, withIntermediateDirectories: true, attributes: nil)
                print("✅ Created state directory: \(pomodoroDir.path)")
            } catch {
                print("❌ Failed to create state directory: \(error)")
            }
        }
        
        self.fileURL = pomodoroDir.appendingPathComponent("state.json")
        
        // Configure JSON encoder for consistency
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        print("📁 StateManager initialized with file: \(fileURL.path)")
    }
    
    /// Atomically write timer state to JSON file
    /// Uses temporary file + rename pattern to prevent corruption
    func writeState(_ state: TimerState) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                // Encode state to JSON data
                let data = try self.encoder.encode(state)
                
                // Create temporary file for atomic write
                let tempURL = self.fileURL.appendingPathExtension(UUID().uuidString)
                
                // Write to temporary file
                try data.write(to: tempURL, options: .atomic)
                
                // Atomic rename to replace existing file
                if FileManager.default.fileExists(atPath: self.fileURL.path) {
                    _ = try FileManager.default.replaceItem(at: self.fileURL, withItemAt: tempURL, backupItemName: nil, options: [], resultingItemURL: nil)
                } else {
                    try FileManager.default.moveItem(at: tempURL, to: self.fileURL)
                }
                
                print("💾 State written: \(state.phase) - \(state.timeRemaining)s - running: \(state.isRunning)")
                
            } catch {
                print("❌ Failed to write state: \(error)")
                
                // Clean up temporary file on error
                let tempURL = self.fileURL.appendingPathExtension(UUID().uuidString)
                try? FileManager.default.removeItem(at: tempURL)
            }
        }
    }
    
    /// Read and validate timer state from JSON file
    /// Returns nil if file doesn't exist, is corrupted, or stale
    func readState() -> TimerState? {
        return queue.sync { [weak self] in
            guard let self = self else { return nil }
            
            // Check if file exists
            guard FileManager.default.fileExists(atPath: self.fileURL.path) else {
                print("📂 No state file found")
                return nil
            }
            
            do {
                // Read and decode JSON data
                let data = try Data(contentsOf: self.fileURL)
                let state = try self.decoder.decode(TimerState.self, from: data)
                
                // Validate state is not stale (within last 10 seconds)
                let now = Date().timeIntervalSince1970
                let staleness = now - state.lastUpdateTimestamp
                
                if staleness > 10.0 {
                    print("⚠️ State file is stale (age: \(Int(staleness))s), ignoring")
                    return nil
                }
                
                // Validate process is still running
                if !isProcessRunning(pid: state.appPid) {
                    print("⚠️ App process \(state.appPid) is no longer running, ignoring stale state")
                    return nil
                }
                
                print("📖 State read: \(state.phase) - \(state.timeRemaining)s - running: \(state.isRunning)")
                return state
                
            } catch {
                print("❌ Failed to read state: \(error)")
                return nil
            }
        }
    }
    
    /// Remove state file (for cleanup or reset)
    func clearState() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            if FileManager.default.fileExists(atPath: self.fileURL.path) {
                do {
                    try FileManager.default.removeItem(at: self.fileURL)
                    print("🗑️ State file cleared")
                } catch {
                    print("❌ Failed to clear state file: \(error)")
                }
            }
        }
    }
    
    /// Check if a process with given PID is still running
    private func isProcessRunning(pid: Int32) -> Bool {
        return kill(pid, 0) == 0
    }
    
    /// Get the current state file path (for debugging/configuration)
    var stateFilePath: String {
        return fileURL.path
    }
}