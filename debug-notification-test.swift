#!/usr/bin/env swift

import Foundation

print("Sending test notification...")

let center = DistributedNotificationCenter.default()
let testName = Notification.Name("test.debug.notification")

center.post(name: testName, object: nil, userInfo: ["test": "value"])

print("Test notification sent: \(testName.rawValue)")

// Also try our specific notification
let pomodoroName = Notification.Name("com.local.PomodoroTimer.toggle")
center.post(name: pomodoroName, object: nil, userInfo: nil)

print("Pomodoro notification sent: \(pomodoroName.rawValue)")