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
- **Real-time Display**: Shows current timer state in your SketchyBar with immediate updates
- **Bidirectional Control**: Click SketchyBar item to control timer
- **Performance Optimized**: 98% reduction in system calls through intelligent state caching
- **Fault Tolerant**: Automatic recovery from connection failures with exponential backoff

### 🎨 Design & UX
- **Alfred-Style Auto-Hide**: Overlay automatically disappears when losing focus - clean, intuitive UX
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
- **JSON State File**: `~/.config/pomodoro-timer/state.json` for real-time SketchyBar integration

## 🎮 Usage

### Control Methods

**Menu Bar (Primary)**
- Click 🍅 icon in menu bar for all timer controls
- Color-coded status: Red (running), Yellow (overlay visible), Tomato (idle)

**Global Hotkey**
- `Opt+Shift+P`: Toggle overlay (works system-wide)

**Overlay Controls (when visible)**
- `Space`: Start/pause timer
- `R`: Reset timer
- `S`: Skip phase  
- `T`: Open theme picker
- `O` / `ESC`: Hide overlay (or simply click on another app to auto-hide)

**URL Schemes (for automation)**
- `open "pomodoro://toggle"`: Start/pause timer
- `open "pomodoro://reset"`: Reset timer
- `open "pomodoro://skip"`: Skip phase
- `open "pomodoro://show-app"`: Show overlay

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

### Themes
Switch themes using the `T` key when overlay is visible, or create custom themes:

**Built-in Themes:**
- **Minimal**: Circular progress with clean aesthetics
- **Grid**: GitHub contribution grid visualization
- **Terminal**: Command-line interface style
- **Aura**: Minimalist design with subtle colors

**Custom Themes:**
See [THEME_DEVELOPMENT_GUIDE.md](THEME_DEVELOPMENT_GUIDE.md) for creating custom themes with the new protocol-oriented architecture.

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


## 📱 Compatibility

### Aerospace Tiling Manager
- Fully compatible with aerospace window management
- Maintains standard window properties for proper tiling
- Transparent background preserves tiling manager APIs

### System Integration
- **Lock Screen**: Notifications work when Mac is locked or sleeping
- **Music Apps**: Doesn't interfere with ongoing music playback
- **Focus Modes**: Compatible with macOS Do Not Disturb settings

## 📚 Documentation

- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**: Common issues and solutions
- **[THEME_DEVELOPMENT_GUIDE.md](THEME_DEVELOPMENT_GUIDE.md)**: Create custom themes
- **[SECURITY.md](SECURITY.md)**: Privacy-safe architecture details  
- **[CHANGELOG.md](CHANGELOG.md)**: Version history and migration guides
- **[pomodoro_app.md](pomodoro_app.md)**: Complete development history and technical decisions

## 🛠️ Quick Troubleshooting

### Notifications Not Appearing
1. System Preferences → Notifications → Pomodoro Timer
2. Enable "Lock Screen" and "Banners"
3. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions

### Global Hotkey Not Working
1. Try Menu Bar → "Toggle Overlay" 
2. Use URL scheme: `open "pomodoro://show-app"`
3. Check for hotkey conflicts with other apps

### SketchyBar Issues
1. Run: `cd sketchybar_scripts && ./install.sh`
2. Verify: `ls ~/.config/sketchybar/helpers/pomodoro_app_*`
3. See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for complete guide

## 🎨 Credits

**App Icon**: [Tomato icon](https://www.flaticon.com/free-icon/tomato_411007) by [Freepik](https://www.freepik.com) from [Flaticon](https://www.flaticon.com)

## 📄 License

This project is open source. See the code for implementation details and feel free to contribute improvements.

## 🏗️ Project History

This app evolved from shell script prototypes to address the fundamental limitation that lock-screen notifications require a proper macOS app with UserNotifications.framework. Earlier versions using `osascript` notifications failed when the Mac was locked.

For complete development history and technical decisions, see `pomodoro_app.md`.

---

**Current Version**: 3.0.2  
**Last Updated**: 2025-08-04  
**Minimum macOS**: 13.0