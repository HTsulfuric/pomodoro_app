import SwiftUI
import UserNotifications
import Combine
import AppKit
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate, NSWindowDelegate {
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    
    // State management (moved from PomodoroTimerApp)
    let timerViewModel = TimerViewModel()
    
    // Screen context for dynamic theme sizing
    let screenContext = ScreenContext()
    
    // Floating overlay window components
    var overlayPanel: OverlayPanel?
    private var hostingController: NSHostingController<AnyView>?
    
    // REMOVED: Permission handling (no longer needed - privacy fix)
    // private var permissionWindow: NSWindow?
    // private var hasAccessibilityPermission: Bool { AXIsProcessTrusted() }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        Logger.lifecycle("AppDelegate.applicationDidFinishLaunching")
        
        // Register built-in themes with the registry
        ThemeRegistrationHelper.registerBuiltInThemes()
        
        // Configure app for menu bar mode
        NSApplication.shared.setActivationPolicy(.accessory)
        
        // Setup notification delegate
        UNUserNotificationCenter.current().delegate = self
        NotificationManager.shared.requestPermission()
        
        // Setup KeyboardManager with TimerViewModel reference (no permissions needed)
        KeyboardManager.shared.timerViewModel = timerViewModel
        
        // Setup notification observers for overlay control
        setupOverlayNotificationObservers()
        
        // Setup app components (no permissions required for menu bar integration)
        setupAppComponents()
        
        Logger.lifecycle("App initialization complete")
    }
    
    // MARK: - App Component Setup (Privacy-Safe)
    
    private func setupAppComponents() {
        // Setup UI components
        setupFloatingOverlay()
        
        // Setup local keyboard manager (no permissions required)
        KeyboardManager.shared.startKeyboardMonitoring()
        
        Logger.info("App setup complete with menu bar integration (no invasive permissions required)", category: .app)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up keyboard monitoring
        KeyboardManager.shared.stopKeyboardMonitoring()
        
        // Ensure sleep prevention is stopped
        SleepPreventionManager.shared.stopPreventingSleep()
        
        cancellables.removeAll()
        Logger.lifecycle("App terminating")
    }
    
    deinit {
        KeyboardManager.shared.stopKeyboardMonitoring()
        SleepPreventionManager.shared.stopPreventingSleep()
        cancellables.removeAll()
    }
    
    // MARK: - Floating Overlay Setup
    
    private func setupFloatingOverlay() {
        // Create floating panel centered on screen (use current theme size, not minimal)
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        let windowSize = timerViewModel.currentTheme.preferredWindowSize // Use current theme size
        let panelFrame = NSRect(
            x: (screenFrame.width - windowSize.width) / 2,
            y: (screenFrame.height - windowSize.height) / 2,
            width: windowSize.width,
            height: windowSize.height
        )
        
        // Create Alfred-style overlay panel (key difference!)
        overlayPanel = OverlayPanel(contentRect: panelFrame)
        
        guard let panel = overlayPanel else {
            Logger.error("Failed to create overlay panel", category: .overlay)
            return
        }
        
        // Create hosting controller with ContentView.
        // The problematic .frame modifier is removed to prevent a layout feedback loop.
        let contentView = AnyView(
            ContentView()
                .environmentObject(timerViewModel)
                .environmentObject(screenContext)
        )

        hostingController = NSHostingController(rootView: contentView)

        // CRITICAL: Set sizing options to empty set to break the layout recursion.
        // This prevents NSHostingController from creating constraints based on SwiftUI content size,
        // making the AppKit-managed panel the definitive source of truth for sizing.
        hostingController?.sizingOptions = []
        
        panel.contentViewController = hostingController
        
        // CRITICAL: Set panel content size to full screen
        let fullScreenSize = timerViewModel.currentTheme.preferredWindowSize
        panel.setContentSize(fullScreenSize)
        
        // Ensure hosting controller view fills the panel content
        if let contentView = panel.contentView, let controller = hostingController {
            controller.view.frame = contentView.bounds
            controller.view.autoresizingMask = [.width, .height]
        }
        
        // Set delegate for auto-dismiss behavior
        panel.delegate = self
        
        // Start hidden
        panel.orderOut(nil)
    }
    
    // MARK: - Overlay Control
    
    private func toggleOverlay() {
        guard let panel = overlayPanel else {
            Logger.error("Overlay panel not available", category: .overlay)
            return
        }
        
        if panel.isVisible {
            hideOverlay()
        } else {
            showOverlay()
        }
    }
    
    private func showOverlay() {
        guard let panel = overlayPanel else {
            Logger.error("No overlay panel available", category: .overlay)
            return
        }
        
        // Center panel on current screen and resize if screen changed
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            let currentPanelSize = panel.frame.size
            let expectedPanelSize = timerViewModel.currentTheme.preferredWindowSize
            
            // Update screen context if screen changed (triggers theme re-sizing)
            screenContext.updateScreen(screen)
            
            // CRITICAL FIX: Resize the actual panel if screen changed
            // Compare expected size vs current size to detect if we need to resize
            let sizeMismatch = abs(currentPanelSize.width - expectedPanelSize.width) > 1.0 || 
                              abs(currentPanelSize.height - expectedPanelSize.height) > 1.0
            
            if sizeMismatch {
                // Resize the panel to match the new screen
                panel.setContentSize(expectedPanelSize)
                
                // Update hostingController view frame to match new panel size
                if let contentView = panel.contentView, let controller = hostingController {
                    controller.view.frame = contentView.bounds
                    controller.view.autoresizingMask = [.width, .height]
                }
            }
            
            // Center the panel on the new screen
            let finalPanelSize = panel.frame.size // Get the actual size after potential resize
            let newOrigin = NSPoint(
                x: (screenFrame.width - finalPanelSize.width) / 2 + screenFrame.minX,
                y: (screenFrame.height - finalPanelSize.height) / 2 + screenFrame.minY
            )
            panel.setFrameOrigin(newOrigin)
        }
        
        // CRITICAL: Only make key window, DON'T activate the application
        // This is the key difference from our old approach that stole focus
        panel.makeKeyAndOrderFront(nil)
        
        // Notify KeyboardManager that overlay is now visible
        KeyboardManager.shared.isOverlayVisible = true
        
        // Start sleep prevention when overlay is shown
        SleepPreventionManager.shared.startPreventingSleep()
    }
    
    private func hideOverlay() {
        overlayPanel?.orderOut(nil)
        
        // Notify KeyboardManager that overlay is now hidden
        KeyboardManager.shared.isOverlayVisible = false
        
        // Stop sleep prevention when overlay is hidden
        SleepPreventionManager.shared.stopPreventingSleep()
        
        Logger.overlay("Floating overlay hidden")
    }
    
    // MARK: - Global Keyboard Monitoring
    
    // MARK: - Overlay Notification Observers
    
    private func setupOverlayNotificationObservers() {
        // Listen for overlay toggle requests from KeyboardManager
        NotificationCenter.default.publisher(for: .toggleOverlay)
            .sink { [weak self] _ in
                Logger.overlay("Toggle overlay notification received")
                self?.toggleOverlay()
            }
            .store(in: &cancellables)
        
        // Listen for overlay hide requests from KeyboardManager
        NotificationCenter.default.publisher(for: .hideOverlay)
            .sink { [weak self] _ in
                Logger.overlay("Hide overlay notification received")
                self?.hideOverlay()
            }
            .store(in: &cancellables)
        
        // Note: Dynamic sizing removed - all themes now use full screen
        
        Logger.overlay("Overlay notification observers setup complete")
        
        // No need to resize - panel will be created with correct theme size
    }
    
    // Public method to restart keyboard monitoring (no permissions needed)
    func checkAndRestartKeyboardMonitoring() {
        KeyboardManager.shared.checkAndRestartIfNeeded()
    }
    
    // MARK: - URL Scheme Handling (moved from PomodoroTimerApp)
    
    func application(_ application: NSApplication, open urls: [URL]) {
        Logger.info("AppDelegate.application:open called with URLs: \(urls)", category: .app)
        
        for url in urls {
            handleURLCommand(url)
        }
    }
    
    private func handleURLCommand(_ url: URL) {
        Logger.debug("handleURLCommand called with URL: \(url)", category: .app)
        
        guard url.scheme == "pomodoro" else {
            Logger.warning("Unknown URL scheme: \(url.scheme ?? "nil")", category: .app)
            return
        }
        
        guard let command = url.host else {
            Logger.warning("No command found in URL: \(url)", category: .app)
            return
        }
        
        Logger.info("Received URL command: \(command)", category: .app)
        
        // Execute command and optionally show popover
        switch command {
        case "toggle", "toggle-timer":
            handleToggleCommand()
        case "reset", "reset-timer":
            handleResetCommand()
        case "skip", "skip-phase":
            handleSkipCommand()
        case "show-app":
            showOverlay()
        default:
            Logger.warning("Unknown command: \(command)", category: .app)
        }
    }
    
    private func handleToggleCommand() {
        Logger.debug("handleToggleCommand called", category: .app)
        if timerViewModel.pomodoroState.isRunning {
            Logger.info("Pausing timer via URL command", category: .app)
            timerViewModel.pauseTimer()
        } else {
            Logger.info("Starting timer via URL command", category: .app)
            timerViewModel.startTimer()
        }
        Logger.debug("handleToggleCommand completed", category: .app)
    }
    
    private func handleResetCommand() {
        Logger.debug("handleResetCommand called", category: .app)
        Logger.info("Resetting timer via URL command", category: .app)
        timerViewModel.resetTimer()
        Logger.debug("handleResetCommand completed", category: .app)
    }
    
    private func handleSkipCommand() {
        Logger.debug("handleSkipCommand called", category: .app)
        Logger.info("Skipping phase via URL command", category: .app)
        timerViewModel.skipPhase()
        Logger.debug("handleSkipCommand completed", category: .app)
    }
    
    // MARK: - Notification Handling
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // For overlay apps, show overlay when dock icon is clicked (if visible)
        if !flag {
            showOverlay()
        }
        return false
    }
    
    // Handle notification actions when app is running
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Logger.debug("Received notification response: \(response.actionIdentifier)", category: .notifications)
        
        // Handle the notification response
        NotificationManager.shared.handleNotificationResponse(response)
        
        // Only show overlay if user clicked the notification body (not an action button)
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            Logger.debug("User clicked notification body - showing overlay", category: .notifications)
            showOverlay()
        } else {
            Logger.debug("User clicked action button - executing silently", category: .notifications)
        }
        
        completionHandler()
    }
    
    // Show notifications even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    // MARK: - NSWindowDelegate for Auto-Dismiss
    
    // Alfred-style auto-hide behavior: overlay disappears when losing focus
    func windowDidResignKey(_ notification: Notification) {
        // Auto-hide overlay when it loses focus (Alfred-style behavior)
        if notification.object as? NSPanel == overlayPanel {
            Logger.userAction("Overlay lost focus - auto-hiding")
            hideOverlay()
        }
    }
}
