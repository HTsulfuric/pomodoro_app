# Pomodoro Timer v3

A native macOS Pomodoro timer app built with SwiftUI, featuring lock-screen compatible notifications and SketchyBar integration.

![Version](https://img.shields.io/badge/version-3.0-blue)
![Platform](https://img.shields.io/badge/platform-macOS%2013.0+-lightgrey)
![Language](https://img.shields.io/badge/language-Swift-orange)

## ✨ Features

### 🍅 Core Pomodoro Timer
- **Classic Pomodoro Technique**: 25-minute work sessions, 5-minute breaks, 15-minute long breaks
- **Lock-Screen Notifications**: Interactive notifications with "Start Break" and "Skip" buttons that work even when your Mac is locked
- **Audio Alerts**: System sound notifications for phase transitions
- **Session Tracking**: Automatic session counting with daily reset
- **Transparent UI**: Elegant Nord-themed interface with blur effects

### 📊 SketchyBar Integration
- **Real-time Display**: Shows current timer state in your SketchyBar
- **Bidirectional Control**: Click SketchyBar item to control timer
- **Performance Optimized**: 98% reduction in system calls through intelligent state caching
- **Fault Tolerant**: Automatic recovery from connection failures with exponential backoff

### 🎨 Design & UX
- **Pixel Art Icon**: Custom red/green/black tomato icon in retro 8-bit style
- **Nord Color Theme**: Arctic color palette for elegant dark UI
- **Aerospace Compatible**: Resizable window optimized for tiling window managers
- **Compact Interface**: Minimum 300×400px window, perfect for corner placement

## 🚀 Installation

### Requirements
- macOS 13.0 or later
- Notification permissions (granted on first launch)
- Optional: [SketchyBar](https://github.com/FelixKratz/SketchyBar) for menu bar integration

### Quick Start
1. Clone the repository
2. Open `PomodoroTimer/PomodoroTimer.xcodeproj` in Xcode
3. Build and run (⌘+R)
4. Grant notification permissions when prompted

### SketchyBar Integration (Optional)
```bash
cd sketchybar_scripts
./install.sh
```

Then add to your SketchyBar configuration:
```lua
require("items.pomodoro")
```

## 🏗️ Architecture

### Project Structure
```
PomodoroTimer/
├── Models/
│   └── PomodoroTimer.swift      # Core timer logic and state management
├── ViewModels/
│   └── TimerViewModel.swift     # UI state coordination and timer lifecycle
├── Views/
│   └── ContentView.swift        # Main SwiftUI interface
├── Services/
│   ├── NotificationManager.swift  # UserNotifications integration
│   ├── SketchyBarManager.swift   # SketchyBar communication and optimization
│   ├── StateManager.swift        # JSON state persistence
│   └── SoundManager.swift        # Audio management
├── Extensions/
│   ├── NordTheme.swift           # Color theme definitions
│   └── VisualEffectView.swift    # Transparent background effects
└── Assets.xcassets/
    └── AppIcon.appiconset/       # Pixel art tomato icons (16px-512px@2x)
```

### Key Technologies
- **SwiftUI**: Declarative UI with reactive state management
- **UserNotifications.framework**: Lock-screen compatible interactive notifications
- **Combine**: Reactive state updates and notification observation
- **JSON State File**: `~/.config/pomodoro-timer/state.json` for SketchyBar integration

## 🎮 Usage

### Basic Controls
- **Play/Pause**: Start or pause the current timer
- **Skip**: Jump to the next phase (work → break → work)
- **Reset**: Reset current phase to full duration
- **Debug Timer**: 3-second timer for testing notifications

### Notification Interactions
When a phase completes, you'll receive an interactive notification with:
- **Start Break**: Begin the break timer immediately
- **Skip**: Jump directly to the next work session

### SketchyBar Display
The SketchyBar item shows:
- **Timer Display**: MM:SS format countdown
- **Phase Icons**: 🍅 (work), ☕ (break), 🏖️ (long break)
- **Color Coding**: Green (work), yellow (short break), orange (long break)
- **Click Actions**: Left-click to start/pause, right-click for more options

## ⚙️ Configuration

### Timer Durations
Edit `Models/PomodoroTimer.swift`:
```swift
var duration: TimeInterval {
    switch self {
    case .work: return 25 * 60        // 25 minutes
    case .shortBreak: return 5 * 60   // 5 minutes  
    case .longBreak: return 15 * 60   // 15 minutes
    }
}
```

### Colors & Theme
Customize in `Extensions/NordTheme.swift`:
```swift
extension Color {
    static let nordPrimary = Color(hex: "#ECEFF4")    // Snow Storm
    static let nordAccent = Color(hex: "#A3BE8C")     // Aurora Green
    // ... more colors
}
```

### SketchyBar Integration
Toggle integration in the app or modify `Services/SketchyBarManager.swift` for advanced customization.

## 🔧 Development

### Building
```bash
cd PomodoroTimer
xcodebuild -project PomodoroTimer.xcodeproj -scheme PomodoroTimer -destination "platform=macOS" build
```

### Testing
Run unit tests and UI tests in Xcode (⌘+U) or via the Test navigator.

### Debug Features
- **3-Second Timer**: For rapid testing of phase transitions
- **Manual Sound Test**: Verify audio notifications work
- **Console Logging**: Detailed state change and notification logs

## 📱 Compatibility

### Aerospace Tiling Manager
- Fully compatible with aerospace window management
- Maintains standard window properties for proper tiling
- Transparent background preserves tiling manager APIs

### System Integration
- **Lock Screen**: Notifications work when Mac is locked or sleeping
- **Music Apps**: Doesn't interfere with ongoing music playback
- **Focus Modes**: Compatible with macOS Do Not Disturb settings

## 🛠️ Troubleshooting

### Notifications Not Appearing
1. Check System Preferences → Notifications → Pomodoro Timer
2. Ensure "Lock Screen" and "Banners" are enabled
3. Test with the debug 3-second timer

### SketchyBar Not Updating
1. Verify SketchyBar is installed and running
2. Check state file exists: `~/.config/pomodoro-timer/state.json`
3. Run installation script: `cd sketchybar_scripts && ./install.sh`
4. Check SketchyBar logs for errors

### Window Issues
- **Too Small**: Minimum size is 300×400px
- **Not Transparent**: Restart app if visual effects don't load
- **Tiling Problems**: Ensure aerospace is updated to latest version

## 🎨 Credits

**App Icon**: [Tomato icon](https://www.flaticon.com/free-icon/tomato_411007) by [Freepik](https://www.freepik.com) from [Flaticon](https://www.flaticon.com)

## 📄 License

This project is open source. See the code for implementation details and feel free to contribute improvements.

## 🏗️ Project History

This app evolved from shell script prototypes to address the fundamental limitation that lock-screen notifications require a proper macOS app with UserNotifications.framework. Earlier versions using `osascript` notifications failed when the Mac was locked.

For complete development history and technical decisions, see `pomodoro_app.md`.

---

**Current Version**: 3.0  
**Last Updated**: 2025-07-21  
**Minimum macOS**: 13.0