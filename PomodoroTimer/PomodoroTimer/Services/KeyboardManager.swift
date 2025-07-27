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
            Logger.keyboard("Overlay visibility changed to \(isOverlayVisible)")
        }
    }
    
    // MARK: - Permission handling
    private var hasAccessibilityPermission: Bool {
        return AXIsProcessTrusted()
    }
    
    // MARK: - Initialization
    private init() {
        Logger.keyboard("KeyboardManager initialized")
    }
    
    deinit {
        stopKeyboardMonitoring()
    }
    
    // MARK: - Public Interface
    
    /// Start keyboard monitoring (requires accessibility permissions)
    func startKeyboardMonitoring() {
        guard hasAccessibilityPermission else {
            Logger.warning("Cannot start keyboard monitoring - accessibility permissions required", category: .permissions)
            return
        }
        
        guard globalKeyMonitor == nil else {
            Logger.keyboard("Keyboard monitoring already active")
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
        
        Logger.info("Global keyboard monitoring started (Opt+Shift+P + overlay keys)", category: .keyboard)
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
        
        Logger.info("Keyboard monitoring stopped", category: .keyboard)
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
            Logger.keyboard("Global Opt+Shift+P detected - toggling overlay")
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
            Logger.keyboard("Local Opt+Shift+P detected - toggling overlay")
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
    
    private func handleThemePickerKey(_ event: NSEvent, viewModel: TimerViewModel) -> Bool {
        guard !event.modifierFlags.contains([.command, .control, .option, .shift]) else {
            return false // Don't handle modified keys
        }
        
        switch event.keyCode {
        case 38: // j key
            Logger.keyboard("j key - next theme")
            viewModel.selectNextTheme()
            return true
        case 40: // k key
            Logger.keyboard("k key - previous theme")
            viewModel.selectPreviousTheme()
            return true
        case 125: // Down arrow
            Logger.keyboard("Down arrow - next theme")
            viewModel.selectNextTheme()
            return true
        case 126: // Up arrow
            Logger.keyboard("Up arrow - previous theme")
            viewModel.selectPreviousTheme()
            return true
        case 36: // Enter key
            Logger.keyboard("Enter key - confirm theme selection")
            viewModel.confirmThemeSelection()
            return true
        case 53: // ESC key
            Logger.keyboard("ESC key - cancel theme selection")
            viewModel.cancelThemeSelection()
            return true
        default:
            return false // Don't consume other keys
        }
    }
    
    private func handleOverlaySpecificKey(_ event: NSEvent) -> Bool {
        guard let viewModel = timerViewModel else {
            Logger.warning("TimerViewModel not available", category: .keyboard)
            return false
        }
        
        // Handle theme picker keys when theme picker is visible
        if viewModel.isThemePickerPresented {
            return handleThemePickerKey(event, viewModel: viewModel)
        }
        
        // Handle T key to activate theme picker when overlay is visible but theme picker is not
        if event.keyCode == 17 && !event.modifierFlags.contains([.command, .control, .option, .shift]) { // T key
            Logger.keyboard("T key - opening theme picker")
            viewModel.presentThemePicker()
            return true
        }
        
        switch event.keyCode {
        case 49: // Space key
            if !event.modifierFlags.contains([.command, .control, .option, .shift]) {
                if viewModel.pomodoroState.isRunning {
                    Logger.keyboard("Space key - pausing timer (keep overlay visible)")
                    viewModel.pauseTimer()
                    // Post notification for quick visual feedback (pause action)
                    NotificationCenter.default.post(name: .spaceKeyPressed, object: nil)
                } else {
                    Logger.keyboard("Space key - starting timer with enhanced feedback (keep overlay visible)")
                    viewModel.startTimer()
                    // Post notification for enhanced visual feedback (start action)
                    NotificationCenter.default.post(name: .spaceKeyStartPressed, object: nil)
                }
                return true
            }
        case 15: // R key
            if !event.modifierFlags.contains([.command, .control, .option, .shift]) {
                Logger.keyboard("R key - resetting timer")
                viewModel.resetTimer()
                // Post notification for visual feedback only
                NotificationCenter.default.post(name: .resetKeyPressed, object: nil)
                return true
            }
        case 1: // S key
            if !event.modifierFlags.contains([.command, .control, .option, .shift]) {
                Logger.keyboard("S key - skipping phase")
                viewModel.skipPhase()
                // Post notification for visual feedback only
                NotificationCenter.default.post(name: .skipKeyPressed, object: nil)
                return true
            }
        case 31: // O key
            if !event.modifierFlags.contains([.command, .control, .option, .shift]) {
                Logger.keyboard("O key - hiding overlay")
                // Post notification for AppDelegate to hide overlay
                NotificationCenter.default.post(name: .hideOverlay, object: nil)
                return true
            }
        case 53: // ESC key
            if !event.modifierFlags.contains([.command, .control, .option, .shift]) {
                Logger.keyboard("ESC key - hiding overlay")
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