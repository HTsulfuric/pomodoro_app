import Foundation
import AppKit

/// Centralized keyboard input manager for the Pomodoro app
/// Handles all global hotkeys and overlay-specific keys in one place
class KeyboardManager {
    // MARK: - Singleton
    static let shared = KeyboardManager()
    
    // MARK: - Properties
    private var globalKeyMonitor: Any?
    private var localKeyMonitor: Any?
    weak var timerViewModel: TimerViewModel?
    
    /// Tracks whether the overlay is visible to determine which keys are active
    var isOverlayVisible: Bool = false {
        didSet {
            print("🎹 KeyboardManager: overlay visibility changed to \(isOverlayVisible)")
        }
    }
    
    // MARK: - Permission handling
    private var hasAccessibilityPermission: Bool {
        return AXIsProcessTrusted()
    }
    
    // MARK: - Initialization
    private init() {
        print("🎹 KeyboardManager initialized")
    }
    
    deinit {
        stopKeyboardMonitoring()
    }
    
    // MARK: - Public Interface
    
    /// Start keyboard monitoring (requires accessibility permissions)
    func startKeyboardMonitoring() {
        guard hasAccessibilityPermission else {
            print("🎹 Cannot start keyboard monitoring - accessibility permissions required")
            return
        }
        
        guard globalKeyMonitor == nil else {
            print("🎹 Keyboard monitoring already active")
            return
        }
        
        // Global monitoring for all hotkeys
        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleGlobalKeyEvent(event)
        }
        
        // Local monitoring when app is focused
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            return self?.handleLocalKeyEvent(event) == true ? nil : event
        }
        
        print("🎹 Global keyboard monitoring started (Opt+Shift+P + overlay keys)")
    }
    
    /// Stop keyboard monitoring
    func stopKeyboardMonitoring() {
        if let monitor = globalKeyMonitor {
            NSEvent.removeMonitor(monitor)
            globalKeyMonitor = nil
        }
        
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyMonitor = nil
        }
        
        print("🎹 Keyboard monitoring stopped")
    }
    
    /// Check and restart monitoring if permissions were granted
    func checkAndRestartIfNeeded() {
        if hasAccessibilityPermission && globalKeyMonitor == nil {
            startKeyboardMonitoring()
        }
    }
    
    // MARK: - Key Event Handling
    
    private func handleGlobalKeyEvent(_ event: NSEvent) {
        // Handle Opt+Shift+P for overlay toggle (works globally)
        if event.keyCode == 35 && // P key
           event.modifierFlags.contains([.option, .shift]) &&
           !event.modifierFlags.contains([.command, .control]) {
            print("🎹 Global Opt+Shift+P detected - toggling overlay")
            handleOverlayToggle()
            return
        }
        
        // Handle overlay-specific keys (only when overlay is visible)
        if isOverlayVisible {
            _ = handleOverlaySpecificKey(event)
        }
    }
    
    private func handleLocalKeyEvent(_ event: NSEvent) -> Bool {
        // Handle Opt+Shift+P for overlay toggle (when app is focused)
        if event.keyCode == 35 && // P key
           event.modifierFlags.contains([.option, .shift]) &&
           !event.modifierFlags.contains([.command, .control]) {
            print("🎹 Local Opt+Shift+P detected - toggling overlay")
            handleOverlayToggle()
            return true // Consume the event
        }
        
        // Handle overlay-specific keys (only when overlay is visible)
        if isOverlayVisible {
            return handleOverlaySpecificKey(event)
        }
        
        return false // Don't consume the event
    }
    
    private func handleOverlayToggle() {
        // Post notification for AppDelegate to toggle overlay display
        NotificationCenter.default.post(name: .toggleOverlay, object: nil)
    }
    
    private func handleOverlaySpecificKey(_ event: NSEvent) -> Bool {
        guard let viewModel = timerViewModel else {
            print("🎹 Warning: TimerViewModel not available")
            return false
        }
        
        switch event.keyCode {
        case 49: // Space key
            if !event.modifierFlags.contains([.command, .control, .option, .shift]) {
                if viewModel.pomodoroState.isRunning {
                    print("🎹 Space key - pausing timer (keep overlay visible)")
                    viewModel.pauseTimer()
                    // Post notification for quick visual feedback (pause action)
                    NotificationCenter.default.post(name: .spaceKeyPressed, object: nil)
                } else {
                    print("🎹 Space key - starting timer with enhanced feedback (keep overlay visible)")
                    viewModel.startTimer()
                    // Post notification for enhanced visual feedback (start action)
                    NotificationCenter.default.post(name: .spaceKeyStartPressed, object: nil)
                }
                return true
            }
        case 15: // R key
            if !event.modifierFlags.contains([.command, .control, .option, .shift]) {
                print("🎹 R key - resetting timer")
                viewModel.resetTimer()
                // Post notification for visual feedback only
                NotificationCenter.default.post(name: .resetKeyPressed, object: nil)
                return true
            }
        case 1: // S key
            if !event.modifierFlags.contains([.command, .control, .option, .shift]) {
                print("🎹 S key - skipping phase")
                viewModel.skipPhase()
                // Post notification for visual feedback only
                NotificationCenter.default.post(name: .skipKeyPressed, object: nil)
                return true
            }
        case 31: // O key
            if !event.modifierFlags.contains([.command, .control, .option, .shift]) {
                print("🎹 O key - hiding overlay")
                // Post notification for AppDelegate to hide overlay
                NotificationCenter.default.post(name: .hideOverlay, object: nil)
                return true
            }
        case 53: // ESC key
            if !event.modifierFlags.contains([.command, .control, .option, .shift]) {
                print("🎹 ESC key - hiding overlay")
                // Post notification for AppDelegate to hide overlay
                NotificationCenter.default.post(name: .hideOverlay, object: nil)
                return true
            }
        default:
            break
        }
        
        return false // Don't consume other keys
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let toggleOverlay = Notification.Name("toggleOverlay")
    static let hideOverlay = Notification.Name("hideOverlay")
    static let spaceKeyPressed = Notification.Name("spaceKeyPressed")
    static let spaceKeyStartPressed = Notification.Name("spaceKeyStartPressed")
    static let resetKeyPressed = Notification.Name("resetKeyPressed")
    static let skipKeyPressed = Notification.Name("skipKeyPressed")
}