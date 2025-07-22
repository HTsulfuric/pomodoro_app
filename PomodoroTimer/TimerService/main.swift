import Foundation

/// Entry point for the Pomodoro Timer XPC Service
/// This service manages the timer state as the single source of truth
/// and provides high-performance, focus-free IPC for the CLI and main app

print("🚀 Pomodoro Timer XPC Service starting...")

let delegate = TimerServiceDelegate()
let listener = NSXPCListener.service()
listener.delegate = delegate

print("🎯 XPC Service listener configured")
print("📡 Service ready to accept connections from main app and CLI")

listener.resume()

print("✅ Pomodoro Timer XPC Service is running")

// Keep the service alive
RunLoop.main.run()