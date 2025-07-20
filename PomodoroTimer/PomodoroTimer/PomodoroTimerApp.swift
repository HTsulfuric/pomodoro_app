import SwiftUI
import UserNotifications
import Combine

@main
struct PomodoroTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var timerViewModel = TimerViewModel()
    @StateObject private var sketchyBarManager = SketchyBarManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 300, minHeight: 400)
                .environmentObject(timerViewModel)
                .environmentObject(sketchyBarManager)
                .onAppear {
                    // Initialize SketchyBar integration on app launch
                    setupSketchyBarIntegration()
                }
                .onOpenURL { url in
                    handleURLCommand(url)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowBackgroundDragBehavior(.enabled)
    }
    
    // MARK: - SketchyBar Integration
    
    private func setupSketchyBarIntegration() {
        print("🚀 Setting up SketchyBar integration")
        
        // Send initial state to SketchyBar
        let initialState = TimerState(
            from: timerViewModel.pomodoroState,
            sessionCount: timerViewModel.totalSessionsToday
        )
        sketchyBarManager.forceUpdate(initialState)
        
        // Set up continuous state monitoring
        setupStateMonitoring()
        
        print("✅ SketchyBar integration initialized")
    }
    
    private func setupStateMonitoring() {
        // Monitor timer state changes
        timerViewModel.$pomodoroState
            .combineLatest(timerViewModel.$totalSessionsToday)
            .sink { [weak sketchyBarManager] pomodoroState, sessionCount in
                let state = TimerState(from: pomodoroState, sessionCount: sessionCount)
                sketchyBarManager?.updateState(state)
            }
            .store(in: &appDelegate.cancellables)
    }
    
    // MARK: - URL Command Handling
    
    private func handleURLCommand(_ url: URL) {
        guard url.scheme == "pomodoro" else {
            print("⚠️ Unknown URL scheme: \(url.scheme ?? "nil")")
            return
        }
        
        guard let command = url.host else {
            print("⚠️ No command found in URL: \(url)")
            return
        }
        
        print("📥 Received URL command: \(command)")
        
        // Bring app to foreground for better user feedback
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        // Execute command
        switch command {
        case "toggle-timer":
            handleToggleCommand()
        case "reset-timer":
            handleResetCommand()
        case "skip-phase":
            handleSkipCommand()
        case "show-app":
            // App is already activated above
            break
        default:
            print("⚠️ Unknown command: \(command)")
        }
    }
    
    private func handleToggleCommand() {
        if timerViewModel.pomodoroState.isRunning {
            print("⏸️ Pausing timer via URL command")
            timerViewModel.pauseTimer()
        } else {
            print("▶️ Starting timer via URL command")
            timerViewModel.startTimer()
        }
    }
    
    private func handleResetCommand() {
        print("🔄 Resetting timer via URL command")
        timerViewModel.resetTimer()
    }
    
    private func handleSkipCommand() {
        print("⏭️ Skipping phase via URL command")
        timerViewModel.skipPhase()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        NotificationManager.shared.requestPermission()
        
        // Configure app for aerospace compatibility
        NSApplication.shared.setActivationPolicy(.regular)
    }
    
    // Handle notification actions when app is running
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationManager.shared.handleNotificationResponse(response)
        completionHandler()
    }
    
    // Show notifications even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
