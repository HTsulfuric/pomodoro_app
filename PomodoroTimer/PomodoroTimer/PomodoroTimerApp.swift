import SwiftUI

@main
struct PomodoroTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Settings scene provides standard menu bar (App -> Quit) for menu bar apps
        Settings {
            EmptyView()
        }
    }
}
