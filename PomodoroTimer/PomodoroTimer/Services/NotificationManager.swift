import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // Notification categories and actions
    private let workCompleteCategory = "WORK_COMPLETE"
    private let breakCompleteCategory = "BREAK_COMPLETE"
    
    private let startBreakAction = UNNotificationAction(
        identifier: "START_BREAK",
        title: "Start Break",
        options: [.foreground]
    )
    
    private let skipBreakAction = UNNotificationAction(
        identifier: "SKIP_BREAK",
        title: "Skip Break",
        options: []
    )
    
    private let startWorkAction = UNNotificationAction(
        identifier: "START_WORK",
        title: "Start Work",
        options: [.foreground]
    )
    
    private let skipWorkAction = UNNotificationAction(
        identifier: "SKIP_WORK",
        title: "Skip Work",
        options: []
    )
    
    init() {
        setupNotificationCategories()
    }
    
    func requestPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                Logger.error("Notification permission error", category: .notifications, error: error)
            } else {
                Logger.info("Notification permission granted: \(granted)", category: .notifications)
            }
        }
    }
    
    private func setupNotificationCategories() {
        let workCompleteCategory = UNNotificationCategory(
            identifier: workCompleteCategory,
            actions: [startBreakAction, skipBreakAction],
            intentIdentifiers: [],
            options: []
        )
        
        let breakCompleteCategory = UNNotificationCategory(
            identifier: breakCompleteCategory,
            actions: [startWorkAction, skipWorkAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([workCompleteCategory, breakCompleteCategory])
    }
    
    func schedulePhaseCompleteNotification(for phase: PomodoroPhase, sessionCount: Int) {
        let content = UNMutableNotificationContent()
        
        switch phase {
        case .work:
            content.title = "🍅 Work Session Complete!"
            content.body = "Session \(sessionCount) finished. Time for a break?"
            content.categoryIdentifier = workCompleteCategory
        case .shortBreak, .longBreak:
            content.title = "\(phase.emoji) Break Time Over!"
            content.body = "Ready to get back to work?"
            content.categoryIdentifier = breakCompleteCategory
        }
        
        content.sound = UNNotificationSound.defaultCritical
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "phase_complete_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                Logger.error("Failed to schedule notification", category: .notifications, error: error)
            }
        }
    }
    
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        // Post notification to update the timer view model
        switch response.actionIdentifier {
        case "START_BREAK":
            NotificationCenter.default.post(name: .startBreak, object: nil)
        case "SKIP_BREAK":
            NotificationCenter.default.post(name: .skipBreak, object: nil)
        case "START_WORK":
            NotificationCenter.default.post(name: .startWork, object: nil)
        case "SKIP_WORK":
            NotificationCenter.default.post(name: .skipWork, object: nil)
        default:
            break
        }
        
        // Clear badge
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}

extension Notification.Name {
    static let startBreak = Notification.Name("startBreak")
    static let skipBreak = Notification.Name("skipBreak")
    static let startWork = Notification.Name("startWork")
    static let skipWork = Notification.Name("skipWork")
}
