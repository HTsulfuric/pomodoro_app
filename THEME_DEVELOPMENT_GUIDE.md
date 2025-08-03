# Pomodoro Timer Theme Development Guide

Create custom themes for the macOS Pomodoro Timer app in minutes, not hours.

## Quick Start: 5-Minute Theme

### 1. Copy & Paste

Create `Views/Themes/MyTheme.swift`:

```swift
import SwiftUI

struct MyTheme: ThemeDefinition {
    let id = "my-theme"
    let displayName = "My Theme"
    let description = "My custom colors"
    let icon = "paintbrush.fill"
    
    // 🎨 CHANGE THESE COLORS
    let accentColor: ThemeColor = .triPhase(
        work: .blue,        // Work session color
        shortBreak: .green, // Short break color
        longBreak: .purple  // Long break color
    )
    
    let backgroundColor: Color = .black
    
    let primaryTextColor: ThemeColor = .triPhase(
        work: .white, shortBreak: .white, longBreak: .white
    )
    
    let secondaryTextColor: ThemeColor = .triPhase(
        work: .gray, shortBreak: .gray, longBreak: .gray
    )
    
    let timerFont: Font = .system(size: 72, weight: .bold, design: .rounded)
    
    // Button colors (auto-generated from accent)
    let primaryButtonColor: ThemeColor = .triPhase(
        work: .blue.opacity(0.8),
        shortBreak: .green.opacity(0.8), 
        longBreak: .purple.opacity(0.8)
    )
    
    let secondaryButtonColor: ThemeColor = .triPhase(
        work: .gray.opacity(0.6),
        shortBreak: .gray.opacity(0.6),
        longBreak: .gray.opacity(0.6)
    )
    
    let buttonTextColor: ThemeColor = .triPhase(
        work: .white, shortBreak: .white, longBreak: .white
    )
    
    let buttonHoverColor: ThemeColor = .triPhase(
        work: .blue, shortBreak: .green, longBreak: .purple
    )
    
    let buttonShadowColor: Color = .black
    let windowBackgroundType: WindowBackgroundType = .blur
    let windowBackgroundColor: Color = .clear
    
    func createExperience() -> AnyThemeExperience {
        return AnyThemeExperience(MyThemeExperience())
    }
    
    static func register() {
        ThemeRegistry.shared.register(MyTheme())
    }
}

struct MyThemeExperience: ThemeExperience {
    let allowsVisualControls = true
    let preferredInteractionModel = InteractionModel.graphical
    
    @ViewBuilder
    func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> some View {
        // Create your custom view here
        MyCustomTimerView(rippleTrigger: rippleTrigger)
            .environmentObject(viewModel)
            .environmentObject(screenContext)
    }
    
    @ViewBuilder
    func makeControlsView(viewModel: TimerViewModel) -> some View {
        // Reuse standard buttons (defined in MinimalTheme.swift)
        StandardControlsView(viewModel: viewModel)
    }
}

// Your custom timer view
struct MyCustomTimerView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @EnvironmentObject var screenContext: ScreenContext
    @Binding var rippleTrigger: Bool
    
    var body: some View {
        // Simple custom layout - customize this!
        VStack(spacing: screenContext.elementSpacing) {
            Text(viewModel.pomodoroState.formattedTime)
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(viewModel.currentTheme.primaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                .monospacedDigit()
            
            Text(viewModel.pomodoroState.currentPhase.rawValue)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
        }
    }
}
```

### 2. Register Your Theme

Add to `Services/ThemeRegistry.swift` in `registerBuiltInThemes()`:

```swift
static func registerBuiltInThemes() {
    MinimalTheme.register()
    GridTheme.register()
    TerminalTheme.register()
    AuraMinimalistTheme.register()
    MyTheme.register()  // Add this line
    
    if ThemeRegistry.shared.validateRegistry() {
    }
}
```

### 3. Build & Test

Build the project (`⌘+R`) - your theme appears in the picker automatically!

---

## Custom Look: Create Your Own Style

### Option 1: Reuse Existing Theme Views

```swift
@ViewBuilder
func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> some View {
    // Use circular timer from MinimalTheme
    MinimalThemeView(rippleTrigger: rippleTrigger)
        .environmentObject(viewModel)
        .environmentObject(screenContext)
}

// Or use grid visualization from GridTheme
@ViewBuilder
func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> some View {
    GridThemeView(rippleTrigger: rippleTrigger)
        .environmentObject(viewModel)
        .environmentObject(screenContext)
}
```

### Option 2: Create Custom View

```swift
struct MyCustomView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @EnvironmentObject var screenContext: ScreenContext
    @Binding var rippleTrigger: Bool
    
    var body: some View {
        VStack {
            // Custom timer display
            Text(viewModel.pomodoroState.formattedTime)
                .font(.system(size: 96, weight: .black, design: .monospaced))
                .foregroundColor(viewModel.currentTheme.primaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
            
            // Progress bar
            ProgressView(value: viewModel.pomodoroState.progress)
                .progressViewStyle(LinearProgressViewStyle(
                    tint: viewModel.currentTheme.accentColor.color(for: viewModel.pomodoroState.currentPhase)
                ))
                .frame(height: 8)
                .padding(.horizontal, 50)
        }
    }
}
```

Then use it:

```swift
@ViewBuilder
func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> some View {
    MyCustomView(rippleTrigger: rippleTrigger)
        .environmentObject(viewModel)
}
```

---

## Advanced Features

### Hide Controls (Keyboard-Only Theme)

```swift
struct KeyboardOnlyExperience: ThemeExperience {
    let allowsVisualControls = false  // Hide buttons
    let preferredInteractionModel = InteractionModel.commandLine
    
    @ViewBuilder
    func makeControlsView(viewModel: TimerViewModel) -> some View {
        EmptyView()  // No controls shown
    }
}
```

### Full Custom Layout

```swift
@ViewBuilder
func makeFullLayoutView(viewModel: TimerViewModel, statusInfo: StatusInfo, rippleTrigger: Binding<Bool>) -> AnyView? {
    AnyView(
        VStack {
            HStack {
                Text(statusInfo.formattedTime)
                Spacer()
                Text(statusInfo.sessionDisplayText)
            }
            .font(.title2)
            
            Text("My completely custom layout")
            
            Button("Custom Action") { /* do something */ }
        }
        .padding()
    )
}
```

### Custom Keyboard Shortcuts

```swift
func customKeyboardBehavior(for keyCode: UInt16) -> KeyboardBehavior? {
    switch keyCode {
    case 46: // M key
        return .custom {
            print("Custom M key action!")
        }
    default:
        return nil  // Use default behavior
    }
}
```

### Dynamic Sizing (Multi-Monitor Support)

```swift
private var adaptiveSize: CGFloat {
    let screenWidth = screenContext.screenFrame.width
    return max(48, min(96, 72 * (screenWidth / 1920)))
}
```

---

## Technical Reference

### Required Properties

**Theme Identity:**
- `id`: Unique string identifier
- `displayName`: Name shown in picker
- `description`: Short description
- `icon`: SF Symbol name

**Colors:**
- `accentColor`: Main theme color
- `backgroundColor`: Window background
- `primaryTextColor`: Timer text
- `secondaryTextColor`: Label text
- `timerFont`: Timer display font

**Buttons:**
- `primaryButtonColor`: Play/pause button
- `secondaryButtonColor`: Other buttons
- `buttonTextColor`: Button text
- `buttonHoverColor`: Hover effect
- `buttonShadowColor`: Drop shadow

**Window:**
- `windowBackgroundType`: `.blur`, `.solid`, or `.gradient`
- `windowBackgroundColor`: Background color

### Theme Colors

```swift
// Same color for all phases
.triPhase(work: .blue, shortBreak: .blue, longBreak: .blue)

// Different colors per phase
.triPhase(work: .green, shortBreak: .blue, longBreak: .purple)
```

### Interaction Models

- `graphical`: Standard GUI with buttons
- `commandLine`: Keyboard-only, no visible controls
- `hybrid`: Both GUI and keyboard optimized
- `minimal`: Simplified interface

### Available View Components

- `MinimalThemeView`: Circular progress (in MinimalTheme.swift)
- `GridThemeView`: GitHub-style grid (in GridTheme.swift)  
- `TerminalThemeView`: Command line aesthetic (in TerminalTheme.swift)
- `StandardControlsView`: Standard buttons

### Registry Methods

```swift
// Debug
ThemeRegistry.shared.printRegisteredThemes()
ThemeRegistry.shared.validateRegistry()

// Access
ThemeRegistry.shared.theme(withId: "my-theme")
ThemeRegistry.shared.availableThemes
```

### Common Issues

**Theme doesn't appear:** Check registration in `ThemeRegistrationHelper.registerBuiltInThemes()`

**Colors don't change:** Use `.color(for: viewModel.pomodoroState.currentPhase)`

**Performance issues:** Add `.id("timer-\(viewModel.currentTheme.id)")`

---

## Examples

**Monochrome Theme:**
```swift
let accentColor: ThemeColor = .triPhase(work: .white, shortBreak: .white, longBreak: .white)
```

**Seasonal Theme:**
```swift
let accentColor: ThemeColor = .triPhase(work: .orange, shortBreak: .red, longBreak: .yellow)
```

**Corporate Theme:**
```swift
let accentColor: ThemeColor = .triPhase(
    work: Color(red: 0/255, green: 82/255, blue: 204/255),     // Company blue
    shortBreak: Color(red: 54/255, green: 179/255, blue: 126/255), // Company green
    longBreak: Color(red: 54/255, green: 179/255, blue: 126/255)
)
```

---

**Happy theming! 🎨**