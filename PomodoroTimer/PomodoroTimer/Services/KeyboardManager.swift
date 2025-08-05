import Foundation
import AppKit
import Carbon

/// Privacy-safe keyboard input manager for the Pomodoro app
/// SECURITY: Uses Carbon hotkey registration instead of global keylogger
class KeyboardManager {
    // MARK: - Singleton
    static let shared = KeyboardManager()
    
    // MARK: - Properties
    private var localKeyMonitor: Any?
    private var statusItem: NSStatusItem?
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    weak var timerViewModel: AppCoordinator?
    
    /// Tracks whether the overlay is visible to determine which keys are active
    var isOverlayVisible: Bool = false {
        didSet {
            Logger.keyboard("Overlay visibility changed to \(isOverlayVisible)")
            // Thread-safe MainActor call
            Task { @MainActor in
                updateMenuBarStatus()
            }
        }
    }
    
    // MARK: - Menu Bar Integration (Safe Alternative to Global Monitoring)
    
    // MARK: - Initialization
    private init() {
        setupMenuBar()
        Logger.keyboard("KeyboardManager initialized with menu bar integration")
    }
    
    deinit {
        stopKeyboardMonitoring()
        cleanupMenuBar()
    }
    
    // MARK: - Public Interface
    
    /// Start keyboard monitoring (local + Carbon global hotkey)
    func startKeyboardMonitoring() {
        guard localKeyMonitor == nil else {
            Logger.keyboard("Keyboard monitoring already active")
            return
        }
        
        // Local monitoring for overlay keys when app is focused
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            return self?.handleLocalKeyEventSync(event) == true ? nil : event
        }
        
        // Register global hotkey using Carbon (privacy-safe)
        registerGlobalHotkey()
        
        Logger.info("Keyboard monitoring started (local + global hotkey)", category: .keyboard)
    }
    
    /// Stop keyboard monitoring
    func stopKeyboardMonitoring() {
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyMonitor = nil
        }
        
        // Unregister global hotkey
        unregisterGlobalHotkey()
        
        Logger.info("Keyboard monitoring stopped", category: .keyboard)
    }
    
    /// Check and restart monitoring (always available - no permissions needed)
    func checkAndRestartIfNeeded() {
        if localKeyMonitor == nil {
            startKeyboardMonitoring()
        }
    }
    
    // MARK: - Menu Bar Implementation
    
    private func setupMenuBar() {
        // Create status item in menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let statusItem = statusItem else {
            Logger.error("Failed to create status item", category: .keyboard)
            return
        }
        
        // Set up the status item button
        if let button = statusItem.button {
            button.title = "🍅"  // Tomato emoji for Pomodoro
            button.toolTip = "Pomodoro Timer"
        }
        
        // Create menu
        let menu = NSMenu()
        
        // Toggle Overlay item
        let toggleItem = NSMenuItem(title: "Toggle Overlay", action: #selector(menuToggleOverlay), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Timer controls (when overlay visible)
        let startPauseItem = NSMenuItem(title: "Start/Pause Timer", action: #selector(menuToggleTimer), keyEquivalent: "")
        startPauseItem.target = self
        menu.addItem(startPauseItem)
        
        let resetItem = NSMenuItem(title: "Reset Timer", action: #selector(menuResetTimer), keyEquivalent: "")
        resetItem.target = self
        menu.addItem(resetItem)
        
        let skipItem = NSMenuItem(title: "Skip Phase", action: #selector(menuSkipPhase), keyEquivalent: "")
        skipItem.target = self
        menu.addItem(skipItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // SketchyBar Settings item
        let sketchyBarItem = NSMenuItem(title: "SketchyBar Settings...", action: #selector(menuOpenSketchyBarSettings), keyEquivalent: "")
        sketchyBarItem.target = self
        menu.addItem(sketchyBarItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit item
        let quitItem = NSMenuItem(title: "Quit", action: #selector(menuQuit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        
        // Thread-safe MainActor call for initial status update
        Task { @MainActor in
            updateMenuBarStatus()
        }
        Logger.keyboard("Menu bar integration setup complete")
    }
    
    private func cleanupMenuBar() {
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
    }
    
    @MainActor private func updateMenuBarStatus() {
        guard let button = statusItem?.button else { return }
        
        // Update menu bar icon based on timer state
        if let viewModel = timerViewModel {
            if viewModel.pomodoroState.isRunning {
                button.title = "🔴"  // Red for running
            } else if isOverlayVisible {
                button.title = "🟡"  // Yellow for overlay visible
            } else {
                button.title = "🍅"  // Default tomato
            }
        }
    }
    
    // MARK: - Menu Actions
    
    @objc private func menuToggleOverlay() {
        Logger.keyboard("Menu: Toggle overlay")
        handleOverlayToggle()
    }
    
    @MainActor @objc private func menuToggleTimer() {
        Logger.keyboard("Menu: Toggle timer")
        timerViewModel?.toggleTimer()
        updateMenuBarStatus()
    }
    
    @MainActor @objc private func menuResetTimer() {
        Logger.keyboard("Menu: Reset timer")
        timerViewModel?.resetTimer()
        updateMenuBarStatus()
    }
    
    @MainActor @objc private func menuSkipPhase() {
        Logger.keyboard("Menu: Skip phase")
        timerViewModel?.skipPhase()
        updateMenuBarStatus()
    }
    
    @objc private func menuOpenSketchyBarSettings() {
        Logger.keyboard("Menu: Open SketchyBar settings")
        // Post notification to show SketchyBar configuration
        NotificationCenter.default.post(name: .showSketchyBarSettings, object: nil)
    }
    
    @objc private func menuQuit() {
        Logger.keyboard("Menu: Quit app")
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - Key Event Handling (Local Only)
    
    /// Thread-safe wrapper for handling local key events
    private func handleLocalKeyEventSync(_ event: NSEvent) -> Bool {
        if Thread.isMainThread {
            // Already on main thread, can call MainActor method directly
            return MainActor.assumeIsolated {
                return handleLocalKeyEvent(event)
            }
        } else {
            // Need to dispatch to main thread synchronously
            var result = false
            DispatchQueue.main.sync {
                result = MainActor.assumeIsolated {
                    return self.handleLocalKeyEvent(event)
                }
            }
            return result
        }
    }
    
    @MainActor private func handleLocalKeyEvent(_ event: NSEvent) -> Bool {
        // REMOVED: Global Opt+Shift+P hotkey (privacy violation)
        // Use menu bar or URL schemes for overlay control instead
        
        // Handle overlay-specific keys (only when overlay is visible and app focused)
        if isOverlayVisible {
            return handleOverlaySpecificKey(event)
        }
        
        return false // Don't consume the event
    }
    
    private func handleOverlayToggle() {
        // Post notification for AppDelegate to toggle overlay display
        NotificationCenter.default.post(name: .toggleOverlay, object: nil)
    }
    
    @MainActor private func handleThemePickerKey(_ event: NSEvent, viewModel: AppCoordinator) -> Bool {
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
    
    @MainActor private func handleSketchyBarSettingsKey(_ event: NSEvent, viewModel: AppCoordinator) -> Bool {
        guard !event.modifierFlags.contains([.command, .control, .option, .shift]) else {
            return false // Don't handle modified keys
        }
        
        // Post the key press for the popup to handle
        NotificationCenter.default.post(
            name: .sketchyBarSettingsKeyPress, 
            object: nil, 
            userInfo: ["keyCode": event.keyCode]
        )
        
        // Always consume keys when settings popup is visible
        return true
    }
    
    @MainActor private func handleOverlaySpecificKey(_ event: NSEvent) -> Bool {
        guard let viewModel = timerViewModel else {
            Logger.warning("AppCoordinator not available", category: .keyboard)
            return false
        }
        
        // Handle theme picker keys when theme picker is visible
        if viewModel.isThemePickerPresented {
            return handleThemePickerKey(event, viewModel: viewModel)
        }
        
        // Handle SketchyBar settings keys when settings popup is visible
        if viewModel.isSketchyBarSettingsPresented {
            return handleSketchyBarSettingsKey(event, viewModel: viewModel)
        }
        
        // Handle T key to activate theme picker when overlay is visible but theme picker is not
        if event.keyCode == 17 && !event.modifierFlags.contains([.command, .control, .option, .shift]) { // T key
            Logger.keyboard("T key - opening theme picker")
            viewModel.presentThemePicker()
            return true
        }
        
        // Handle B key to activate SketchyBar settings when overlay is visible but no other popup is active
        if event.keyCode == 11 && !event.modifierFlags.contains([.command, .control, .option, .shift]) { // B key
            Logger.keyboard("B key - opening SketchyBar settings")
            viewModel.presentSketchyBarSettings()
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
    
    // MARK: - Carbon Global Hotkey Registration (Privacy-Safe)
    
    private func registerGlobalHotkey() {
        // Opt+Shift+P hotkey registration using Carbon
        let hotKeyID = EventHotKeyID(signature: OSType(fourCharCode: "POMO"), id: 1)
        
        // Set up event spec for hotkey pressed events
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), 
                                    eventKind: OSType(kEventHotKeyPressed))
        
        // Install event handler
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (handlerCallRef, event, userData) -> OSStatus in
                // Call the instance method - unwrap optional event
                guard let event = event else { return OSStatus(eventNotHandledErr) }
                return KeyboardManager.shared.handleCarbonHotkey(event: event)
            },
            1,
            &eventType,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            &eventHandler
        )
        
        if status != noErr {
            Logger.warning("Failed to install Carbon event handler: \(status)", category: .keyboard)
            return
        }
        
        // Register the specific hotkey: Opt+Shift+P
        let keyCode = UInt32(35)  // P key
        let modifiers = UInt32(optionKey | shiftKey)  // Opt+Shift
        
        let hotKeyStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if hotKeyStatus == noErr {
            Logger.info("Carbon global hotkey registered: Opt+Shift+P", category: .keyboard)
        } else {
            Logger.warning("Failed to register Carbon hotkey: \(hotKeyStatus)", category: .keyboard)
        }
    }
    
    private func unregisterGlobalHotkey() {
        // Unregister hotkey
        if let hotKeyRef = hotKeyRef {
            let status = UnregisterEventHotKey(hotKeyRef)
            if status == noErr {
                Logger.info("Carbon global hotkey unregistered", category: .keyboard)
            } else {
                Logger.warning("Failed to unregister Carbon hotkey: \(status)", category: .keyboard)
            }
            self.hotKeyRef = nil
        }
        
        // Remove event handler
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }
    
    private func handleCarbonHotkey(event: EventRef) -> OSStatus {
        Logger.keyboard("Carbon hotkey pressed: Opt+Shift+P - toggling overlay")
        
        // Handle the overlay toggle on main thread
        DispatchQueue.main.async {
            self.handleOverlayToggle()
        }
        
        return noErr
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
    static let showSketchyBarSettings = Notification.Name("showSketchyBarSettings")
    static let sketchyBarSettingsKeyPress = Notification.Name("sketchyBarSettingsKeyPress")
}

// MARK: - Carbon Helper Extensions

extension OSType {
    init(fourCharCode: String) {
        precondition(fourCharCode.count == 4, "Four-character code must be exactly 4 characters")
        let chars = Array(fourCharCode.utf8)
        self = UInt32(chars[0]) << 24 | UInt32(chars[1]) << 16 | UInt32(chars[2]) << 8 | UInt32(chars[3])
    }
}
