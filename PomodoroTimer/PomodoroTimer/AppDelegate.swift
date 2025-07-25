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
    
    // Floating overlay window components
    var overlayPanel: OverlayPanel?
    private var hostingController: NSHostingController<AnyView>?
    
    // Debug mode support
    private var debugWindow: NSWindow?
    private let isDebugMode = CommandLine.arguments.contains("--debug-window") || ProcessInfo.processInfo.environment["POMODORO_DEBUG"] != nil
    
    // Permission handling
    private var permissionWindow: NSWindow?
    private var hasAccessibilityPermission: Bool {
        return AXIsProcessTrusted()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print(" AppDelegate.applicationDidFinishLaunching")
        
        // Configure app for menu bar mode
        NSApplication.shared.setActivationPolicy(.accessory)
        
        // Setup notification delegate
        UNUserNotificationCenter.current().delegate = self
        NotificationManager.shared.requestPermission()
        
        // Setup KeyboardManager with TimerViewModel reference
        KeyboardManager.shared.timerViewModel = timerViewModel
        
        // Setup notification observers for overlay control
        setupOverlayNotificationObservers()
        
        // Check accessibility permissions first
        if hasAccessibilityPermission {
            print(" Accessibility permissions granted")
            setupAppWithPermissions()
        } else {
            print(" Accessibility permissions not granted")
            setupAppWithoutPermissions()
            showPermissionWindow()
        }
        
        print(" App initialization complete")
    }
    
    // MARK: - Permission-Based Setup
    
    private func setupAppWithPermissions() {
        // Setup UI components
        if isDebugMode {
            setupDebugWindow()
            print(" Debug mode: Using regular window instead of overlay")
        } else {
            setupFloatingOverlay()
        }
        
        // Setup keyboard manager (requires permissions)
        KeyboardManager.shared.startKeyboardMonitoring()
    }
    
    private func setupAppWithoutPermissions() {
        // Setup UI components (overlay still works, just no global hotkey)
        if isDebugMode {
            setupDebugWindow()
            print(" Debug mode: Using regular window instead of overlay")
        } else {
            setupFloatingOverlay()
        }
        
        // Don't setup keyboard manager
        print(" Global hotkey disabled - accessibility permissions required")
    }
    
    private func showPermissionWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 500),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Accessibility Permission Required"
        window.center()
        window.isReleasedWhenClosed = false
        window.level = .floating // Show above other windows
        
        let permissionView = PermissionView {
            self.dismissPermissionWindow()
        }
        
        let hostingController = NSHostingController(rootView: permissionView)
        window.contentViewController = hostingController
        
        window.makeKeyAndOrderFront(nil)
        
        permissionWindow = window
        print(" Permission guidance window shown")
    }
    
    private func dismissPermissionWindow() {
        permissionWindow?.orderOut(nil)
        permissionWindow = nil
        
        // Check if permissions were granted after user interaction
        if hasAccessibilityPermission {
            print("Accessibility permissions now granted!")
            KeyboardManager.shared.startKeyboardMonitoring()
        } else {
            print(" Continuing without global hotkey functionality")
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up keyboard monitoring
        KeyboardManager.shared.stopKeyboardMonitoring()
        
        // Ensure sleep prevention is stopped
        SleepPreventionManager.shared.stopPreventingSleep()
        
        cancellables.removeAll()
        print(" App terminating")
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
        
        print("🪟 setupFloatingOverlay() - Creating panel with frame: \(panelFrame)")
        print("🪟 setupFloatingOverlay() - Using theme: \(timerViewModel.currentTheme.displayName)")
        print("🪟 setupFloatingOverlay() - Expected size: \(windowSize)")
        
        // Create Alfred-style overlay panel (key difference!)
        overlayPanel = OverlayPanel(contentRect: panelFrame)
        
        guard let panel = overlayPanel else {
            print("🪟 ❌ Failed to create overlay panel")
            return
        }
        
        print("🪟 setupFloatingOverlay() - Panel created with actual frame: \(panel.frame)")
        
        // Create hosting controller with ContentView.
        // The problematic .frame modifier is removed to prevent a layout feedback loop.
        let contentView = AnyView(
            ContentView()
                .environmentObject(timerViewModel)
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
        
        print("🪟 setupFloatingOverlay() - Alfred-style overlay panel created and configured")
    }
    
    // MARK: - Debug Window Setup
    
    private func setupDebugWindow() {
        let preferredSize = timerViewModel.currentTheme.preferredWindowSize // Use current theme size
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: preferredSize.width, height: preferredSize.height),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Pomodoro Timer (Debug Mode)"
        window.center()
        window.isReleasedWhenClosed = false
        
        let contentView = ContentView()
            .environmentObject(timerViewModel)

        let hostingController = NSHostingController(rootView: contentView)
        
        // Use empty sizing options for consistency and to prevent potential layout issues,
        // especially since the debug window is user-resizable.
        hostingController.sizingOptions = []

        window.contentViewController = hostingController
        
        window.makeKeyAndOrderFront(nil)
        
        debugWindow = window
        print(" Debug window created")
    }
    
    // MARK: - Overlay Control
    
    private func toggleOverlay() {
        guard let panel = overlayPanel else {
            print("Overlay panel not available")
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
            print("🪟 ❌ showOverlay() - No panel available")
            return
        }
        
        print("🪟 showOverlay() - Panel frame before show: \(panel.frame)")
        print("🪟 showOverlay() - Panel content size: \(panel.contentView?.frame.size ?? CGSize.zero)")
        
        // Center panel on current screen (in case user moved between monitors)
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            let panelSize = panel.frame.size
            print("🪟 showOverlay() - Screen frame: \(screenFrame)")
            print("🪟 showOverlay() - Panel size: \(panelSize)")
            
            let newOrigin = NSPoint(
                x: (screenFrame.width - panelSize.width) / 2 + screenFrame.minX,
                y: (screenFrame.height - panelSize.height) / 2 + screenFrame.minY
            )
            print("🪟 showOverlay() - Setting panel origin to: \(newOrigin)")
            panel.setFrameOrigin(newOrigin)
        }
        
        // CRITICAL: Only make key window, DON'T activate the application
        // This is the key difference from our old approach that stole focus
        panel.makeKeyAndOrderFront(nil)
        
        print("🪟 showOverlay() - Panel frame after show: \(panel.frame)")
        
        // Notify KeyboardManager that overlay is now visible
        KeyboardManager.shared.isOverlayVisible = true
        
        // Start sleep prevention when overlay is shown
        SleepPreventionManager.shared.startPreventingSleep()
        
        print("🪟 showOverlay() - Alfred-style overlay shown (no focus stealing)")
    }
    
    private func hideOverlay() {
        overlayPanel?.orderOut(nil)
        
        // Notify KeyboardManager that overlay is now hidden
        KeyboardManager.shared.isOverlayVisible = false
        
        // Stop sleep prevention when overlay is hidden
        SleepPreventionManager.shared.stopPreventingSleep()
        
        print(" Floating overlay hidden")
    }
    
    // MARK: - Global Keyboard Monitoring
    
    // MARK: - Overlay Notification Observers
    
    private func setupOverlayNotificationObservers() {
        // Listen for overlay toggle requests from KeyboardManager
        NotificationCenter.default.publisher(for: .toggleOverlay)
            .sink { [weak self] _ in
                print(" Toggle overlay notification received")
                self?.toggleOverlay()
            }
            .store(in: &cancellables)
        
        // Listen for overlay hide requests from KeyboardManager
        NotificationCenter.default.publisher(for: .hideOverlay)
            .sink { [weak self] _ in
                print(" Hide overlay notification received")
                self?.hideOverlay()
            }
            .store(in: &cancellables)
        
        // Note: Dynamic sizing removed - all themes now use full screen
        
        print(" Overlay notification observers setup complete")
        
        // No need to resize - panel will be created with correct theme size
    }
    
    
    // Public method to retry permission setup (can be called from menu or overlay)
    func checkAndSetupGlobalHotkey() {
        KeyboardManager.shared.checkAndRestartIfNeeded()
        if !hasAccessibilityPermission {
            showPermissionWindow()
        }
    }
    
    
    // MARK: - URL Scheme Handling (moved from PomodoroTimerApp)
    
    func application(_ application: NSApplication, open urls: [URL]) {
        print(" AppDelegate.application:open called with URLs: \(urls)")
        
        for url in urls {
            handleURLCommand(url)
        }
    }
    
    private func handleURLCommand(_ url: URL) {
        print(" handleURLCommand called with URL: \(url)")
        
        guard url.scheme == "pomodoro" else {
            print(" Unknown URL scheme: \(url.scheme ?? "nil")")
            return
        }
        
        guard let command = url.host else {
            print(" No command found in URL: \(url)")
            return
        }
        
        print(" Received URL command: \(command)")
        
        // Execute command and optionally show popover
        switch command {
        case "toggle", "toggle-timer":
            handleToggleCommand()
        case "reset", "reset-timer":
            handleResetCommand()
        case "skip", "skip-phase":
            handleSkipCommand()
        case "show-app":
            if !isDebugMode {
                showOverlay()
            }
        default:
            print(" Unknown command: \(command)")
        }
    }
    
    private func handleToggleCommand() {
        print(" handleToggleCommand called")
        if timerViewModel.pomodoroState.isRunning {
            print(" Pausing timer via URL command")
            timerViewModel.pauseTimer()
        } else {
            print(" Starting timer via URL command")
            timerViewModel.startTimer()
        }
        print(" handleToggleCommand completed")
    }
    
    private func handleResetCommand() {
        print(" handleResetCommand called")
        print(" Resetting timer via URL command")
        timerViewModel.resetTimer()
        print(" handleResetCommand completed")
    }
    
    private func handleSkipCommand() {
        print(" handleSkipCommand called")
        print(" Skipping phase via URL command")
        timerViewModel.skipPhase()
        print(" handleSkipCommand completed")
    }
    
    // MARK: - Notification Handling
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // For overlay apps, show overlay when dock icon is clicked (if visible)
        if !isDebugMode && !flag {
            showOverlay()
        }
        return false
    }
    
    // Handle notification actions when app is running
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(" Received notification response: \(response.actionIdentifier)")
        
        // Handle the notification response
        NotificationManager.shared.handleNotificationResponse(response)
        
        // Only show overlay if user clicked the notification body (not an action button)
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            print(" User clicked notification body - showing overlay")
            if !isDebugMode {
                showOverlay()
            }
        } else {
            print(" User clicked action button - executing silently")
        }
        
        completionHandler()
    }
    
    // Show notifications even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    // MARK: - NSWindowDelegate for Auto-Dismiss
    
    func windowDidResignKey(_ notification: Notification) {
        // Auto-hide overlay when it loses focus (Alfred-style behavior)
        if notification.object as? NSPanel == overlayPanel {
            print(" Overlay lost focus - auto-hiding")
            hideOverlay()
        }
    }
}

