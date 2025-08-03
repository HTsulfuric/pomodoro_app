import Foundation
import os.log

/// Professional logging system for the Pomodoro Timer app
/// Provides structured logging with categories, levels, and conditional compilation
class Logger {
    // MARK: - Log Categories
    
    enum Category: String, CaseIterable {
        case app = "App"
        case timer = "Timer"
        case ui = "UI"
        case keyboard = "Keyboard"
        case notifications = "Notifications"
        case themes = "Themes"
        case screen = "Screen"
        case sleep = "Sleep"
        case sound = "Sound"
        case overlay = "Overlay"
        case permissions = "Permissions"
        case registry = "Registry"
        
        var osLog: OSLog {
            OSLog(subsystem: "com.local.PomodoroTimer", category: self.rawValue)
        }
    }
    
    // MARK: - Log Levels
    
    enum Level: String, CaseIterable {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case fault = "FAULT"
        
        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .fault: return .fault
            }
        }
        
        var emoji: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .fault: return "💥"
            }
        }
    }
    
    // MARK: - Configuration
    
    /// Controls whether debug logging is enabled (only in debug builds by default)
    static var isDebugLoggingEnabled: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    /// Controls console output (disabled in release builds)
    static var isConsoleLoggingEnabled: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    // MARK: - Public Logging Methods
    
    /// Log a debug message (only shown in debug builds)
    static func debug(_ message: String, category: Category = .app, file: String = #file, function: String = #function, line: Int = #line) {
        guard isDebugLoggingEnabled else { return }
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    /// Log an informational message
    static func info(_ message: String, category: Category = .app) {
        log(message, level: .info, category: category)
    }
    
    /// Log a warning message
    static func warning(_ message: String, category: Category = .app) {
        log(message, level: .warning, category: category)
    }
    
    /// Log an error message
    static func error(_ message: String, category: Category = .app, error: Error? = nil) {
        var fullMessage = message
        if let error = error {
            fullMessage += " - \(error.localizedDescription)"
        }
        log(fullMessage, level: .error, category: category)
    }
    
    /// Log a critical fault
    static func fault(_ message: String, category: Category = .app) {
        log(message, level: .fault, category: category)
    }
    
    // MARK: - Core Logging Implementation
    
    private static func log(_ message: String, level: Level, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        // Use os_log for system integration
        os_log("%{public}@", log: category.osLog, type: level.osLogType, message)
        
        // Console logging for development
        if isConsoleLoggingEnabled {
            let fileName = (file as NSString).lastPathComponent
            let timestamp = DateFormatter.logTimestamp.string(from: Date())
            
            let consoleMessage: String
            if level == .debug {
                consoleMessage = "\(timestamp) \(level.emoji) [\(category.rawValue)] \(message) (\(fileName):\(line))"
            } else {
                consoleMessage = "\(timestamp) \(level.emoji) [\(category.rawValue)] \(message)"
            }
            
            print(consoleMessage)
        }
    }
    
    // MARK: - Convenience Methods for Common Patterns
    
    /// Log timer state changes
    static func timerState(_ message: String) {
        info(message, category: .timer)
    }
    
    /// Log UI interactions
    static func userAction(_ message: String) {
        info(message, category: .ui)
    }
    
    /// Log keyboard events
    static func keyboard(_ message: String) {
        debug(message, category: .keyboard)
    }
    
    /// Log theme operations
    static func theme(_ message: String) {
        debug(message, category: .themes)
    }
    
    /// Log screen context changes
    static func screen(_ message: String) {
        debug(message, category: .screen)
    }
    
    /// Log overlay operations
    static func overlay(_ message: String) {
        debug(message, category: .overlay)
    }
    
    /// Log notification operations
    static func notification(_ message: String) {
        debug(message, category: .notifications)
    }
    
    /// Log sleep prevention operations
    static func sleep(_ message: String) {
        debug(message, category: .sleep)
    }
    
    /// Log sound operations
    static func sound(_ message: String) {
        debug(message, category: .sound)
    }
    
    /// Log permission operations
    static func permission(_ message: String) {
        info(message, category: .permissions)
    }
    
    /// Log app lifecycle events
    static func lifecycle(_ message: String) {
        info(message, category: .app)
    }
    
    /// Log registry operations
    static func registry(_ message: String) {
        debug(message, category: .registry)
    }
}

// MARK: - DateFormatter Extension

private extension DateFormatter {
    static let logTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}

// MARK: - Migration Helpers

/// Helper methods to ease migration from print statements
extension Logger {
    /// Quick migration from print() - use this temporarily during migration
    @available(*, deprecated, message: "Use appropriate Logger method instead")
    static func migrationHelper(_ message: String, originalFile: String = #file, originalLine: Int = #line) {
        let fileName = (originalFile as NSString).lastPathComponent
        debug("MIGRATION: \(message) (from \(fileName):\(originalLine))")
    }
}
