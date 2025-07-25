# Pomodoro Timer Theme Development Guide

A comprehensive guide for creating custom themes for the macOS Pomodoro Timer app.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Theme Architecture Overview](#theme-architecture-overview)
3. [Creating Your First Theme](#creating-your-first-theme)
4. [Color System Deep Dive](#color-system-deep-dive)
5. [Theme Experience System](#theme-experience-system)
6. [Advanced Features](#advanced-features)
7. [Testing & Debugging](#testing--debugging)
8. [Distribution & Import](#distribution--import)
9. [Best Practices](#best-practices)
10. [API Reference](#api-reference)
11. [Troubleshooting](#troubleshooting)

---

## Quick Start

### 30-Second Theme Creation

1. **Create the theme file**: `Views/Themes/MyAwesomeTheme.swift`
2. **Implement the protocol**: Copy from existing theme, modify colors/properties
3. **Register the theme**: Add `MyAwesomeTheme.register()` to `ThemeRegistrationHelper`
4. **Build and test**: Your theme appears automatically in the picker

**That's it!** No other files need modification.

### Minimal Example

```swift
import SwiftUI

struct MyAwesomeTheme: ThemeDefinition {
    let id = "my-awesome"
    let displayName = "My Awesome Theme"
    let description = "A really awesome custom theme"
    let icon = "star.fill"
    
    // Simple monochrome theme
    let accentColor: ThemeColor = .triPhase(
        work: .purple, shortBreak: .purple, longBreak: .purple
    )
    let backgroundColor: Color = .black
    let primaryTextColor: ThemeColor = .triPhase(
        work: .white, shortBreak: .white, longBreak: .white
    )
    // ... other required properties (see full example below)
    
    func createExperience() -> AnyThemeExperience {
        return AnyThemeExperience(MyAwesomeExperience())
    }
    
    static func register() {
        ThemeRegistry.shared.register(MyAwesomeTheme())
    }
}

struct MyAwesomeExperience: ThemeExperience {
    let allowsVisualControls = true
    let preferredInteractionModel = InteractionModel.graphical
    
    @ViewBuilder
    func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> some View {
        // Use existing view or create custom one
        MinimalThemeView(rippleTrigger: rippleTrigger)
            .environmentObject(viewModel)
    }
    
    @ViewBuilder
    func makeControlsView(viewModel: TimerViewModel) -> some View {
        StandardControlsView(viewModel: viewModel)
    }
}
```

---

## Theme Architecture Overview

### Core Components

The theme system consists of three main components:

```
Theme File (YourTheme.swift)
├── ThemeDefinition (struct)    # Visual properties, metadata
├── ThemeExperience (struct)    # Behavioral properties, view factories
└── Custom Views (optional)     # Theme-specific UI components
```

### Registry System

- **ThemeRegistry**: Singleton that manages all available themes
- **Automatic Discovery**: Themes register themselves on app startup
- **Type Safety**: Type-erased wrappers maintain compile-time safety
- **Thread Safety**: All registry operations are thread-safe

### Integration Points

- **ThemePickerView**: Automatically shows all registered themes
- **TimerViewModel**: Loads/saves themes using registry
- **ContentView**: Uses theme experiences for UI composition

---

## Creating Your First Theme

### Step 1: Choose Your Theme Type

**Graphical Theme (recommended for beginners)**
- Uses standard buttons and controls
- Can reuse existing view components
- Examples: Minimal, Grid themes

**Command-Line Theme (advanced)**
- Invisible controls, keyboard-only interaction
- Requires custom view implementation
- Example: Terminal theme

**Hybrid Theme**
- Mix of graphical and keyboard interactions
- Optimized for both interaction models

### Step 2: Create the Theme File

Create `Views/Themes/YourTheme.swift`:

```swift
import SwiftUI

/// Your custom theme - provide a clear description
struct YourTheme: ThemeDefinition {
    
    // MARK: - Theme Identity
    
    let id = "your-theme"  // Must be unique!
    let displayName = "Your Theme"
    let description = "What makes your theme special"
    let icon = "paintbrush.fill"  // SF Symbol name
    
    // MARK: - Color Properties
    
    let accentColor: ThemeColor = .triPhase(
        work: .blue,        // Work session color
        shortBreak: .green, // Short break color  
        longBreak: .orange  // Long break color
    )
    
    let backgroundColor: Color = .black
    
    let primaryTextColor: ThemeColor = .triPhase(
        work: .white, shortBreak: .white, longBreak: .white
    )
    
    let secondaryTextColor: ThemeColor = .triPhase(
        work: .gray, shortBreak: .gray, longBreak: .gray
    )
    
    let timerFont: Font = .system(size: 64, weight: .bold, design: .rounded)
    
    // MARK: - Button Theme Properties
    
    let primaryButtonColor: ThemeColor = .triPhase(
        work: .blue.opacity(0.8),
        shortBreak: .green.opacity(0.8),
        longBreak: .orange.opacity(0.8)
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
        work: .blue, shortBreak: .green, longBreak: .orange
    )
    
    let buttonShadowColor: Color = .black
    
    // MARK: - Window Theme Properties
    
    let windowBackgroundType: WindowBackgroundType = .solid  // .blur, .solid, or .gradient
    let windowBackgroundColor: Color = .black
    
    // MARK: - Theme Experience Factory
    
    func createExperience() -> AnyThemeExperience {
        return AnyThemeExperience(YourThemeExperience())
    }
    
    // MARK: - Registration
    
    static func register() {
        ThemeRegistry.shared.register(YourTheme())
    }
}

/// Theme experience defines behavior and view factories
struct YourThemeExperience: ThemeExperience {
    
    // MARK: - Behavioral Characteristics
    
    let allowsVisualControls = true  // Set to false for command-line only themes
    let preferredInteractionModel = InteractionModel.graphical
    
    // MARK: - View Factories
    
    @ViewBuilder
    func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> some View {
        // Option 1: Use existing view component
        MinimalThemeView(rippleTrigger: rippleTrigger)
            .environmentObject(viewModel)
        
        // Option 2: Create custom view (see advanced section)
        // YourCustomThemeView(rippleTrigger: rippleTrigger)
        //     .environmentObject(viewModel)
    }
    
    @ViewBuilder
    func makeControlsView(viewModel: TimerViewModel) -> some View {
        // Option 1: Standard controls (recommended)
        StandardControlsView(viewModel: viewModel)
        
        // Option 2: No controls (command-line themes)
        // EmptyView()
        
        // Option 3: Custom controls (advanced)
        // YourCustomControlsView(viewModel: viewModel)
    }
}
```

### Step 3: Register Your Theme

Add your theme to the registration helper in `Services/ThemeRegistry.swift`:

```swift
static func registerBuiltInThemes() {
    MinimalTheme.register()
    GridTheme.register()
    TerminalTheme.register()
    YourTheme.register()  // Add this line
    
    print("✅ Built-in theme registration completed")
    // ...
}
```

### Step 4: Build and Test

1. Build the project (`⌘+R`)
2. Your theme appears in the theme picker automatically
3. Test theme switching and UI updates

---

## Color System Deep Dive

### ThemeColor Enum

The `ThemeColor` system allows themes to define different colors for each Pomodoro phase:

```swift
enum ThemeColor: Equatable {
    case triPhase(work: Color, shortBreak: Color, longBreak: Color)
}
```

### Phase-Aware vs Static Colors

**Phase-Aware Colors** (Dynamic)
```swift
let accentColor: ThemeColor = .triPhase(
    work: .green,       // Work sessions are green
    shortBreak: .blue,  // Short breaks are blue
    longBreak: .purple  // Long breaks are purple
)
```

**Static Colors** (Same across all phases)
```swift
let accentColor: ThemeColor = .triPhase(
    work: .blue, shortBreak: .blue, longBreak: .blue  // Always blue
)
```

### Color Usage in Views

Colors automatically adapt to the current phase:

```swift
Text("Timer")
    .foregroundColor(theme.primaryTextColor.color(for: currentPhase))
```

### Color Properties Reference

| Property | Purpose | Affects |
|----------|---------|---------|
| `accentColor` | Primary theme color | Progress indicators, highlights |
| `backgroundColor` | Theme background | View backgrounds |
| `primaryTextColor` | Main text | Timer display, titles |
| `secondaryTextColor` | Supporting text | Descriptions, metadata |
| `primaryButtonColor` | Main action buttons | Play/pause button |
| `secondaryButtonColor` | Secondary buttons | Reset, skip, sound buttons |
| `buttonTextColor` | Button text | All button labels |
| `buttonHoverColor` | Button hover state | Hover animations |
| `buttonShadowColor` | Button shadows | Button drop shadows |

### Advanced Color Techniques

**Semantic Color Naming**
```swift
// Instead of generic colors, use semantic names
let workColor = Color.green       // Focus and productivity
let breakColor = Color.blue       // Rest and relaxation
let longBreakColor = Color.purple // Deep rest
```

**Accessibility Considerations**
```swift
// Ensure sufficient contrast
let primaryText = Color.white      // High contrast on dark backgrounds
let secondaryText = Color.gray     // Lower contrast for hierarchy
```

**Brand Color Integration**
```swift
// Use your brand colors
extension Color {
    static let brandPrimary = Color(red: 0.2, green: 0.4, blue: 0.8)
    static let brandSecondary = Color(red: 0.8, green: 0.2, blue: 0.4)
}
```

---

## Theme Experience System

### Understanding ThemeExperience

The `ThemeExperience` protocol defines how users interact with your theme:

```swift
protocol ThemeExperience {
    // Behavioral properties
    var allowsVisualControls: Bool { get }
    var preferredInteractionModel: InteractionModel { get }
    var requiresKeyboardFocus: Bool { get }
    
    // View factories
    func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> ContentView
    func makeControlsView(viewModel: TimerViewModel) -> ControlsView
    
    // Advanced customization
    func customKeyboardBehavior(for keyCode: UInt16) -> KeyboardBehavior?
}
```

### Interaction Models

**Graphical (`.graphical`)**
- Traditional GUI with visible buttons
- Mouse and keyboard interaction
- Best for: General users, visual themes

**Command-Line (`.commandLine`)**
- Keyboard-only interaction
- Invisible UI controls
- Best for: Power users, terminal aesthetics

**Hybrid (`.hybrid`)**
- Optimized for both GUI and keyboard
- Visible controls with keyboard shortcuts
- Best for: Flexible themes

**Minimal (`.minimal`)**
- Simplified interaction
- Reduced visual elements
- Best for: Distraction-free themes

### View Factories

**Content View Factory**
```swift
func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> some View {
    // This creates the main timer display
    // Options:
    // 1. Reuse existing view (MinimalThemeView, GridThemeView, TerminalThemeView)
    // 2. Create custom view
    // 3. Compose multiple views
}
```

**Controls View Factory**
```swift
func makeControlsView(viewModel: TimerViewModel) -> some View {
    // This creates the control buttons
    // Options:
    // 1. StandardControlsView (recommended)
    // 2. EmptyView() (command-line themes)
    // 3. Custom controls
}
```

### Custom View Creation

Create a custom view for unique theme experiences:

```swift
struct MyCustomThemeView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @Binding var rippleTrigger: Bool
    
    var body: some View {
        ZStack {
            // Your custom timer visualization
            VStack {
                // Timer display
                Text(viewModel.pomodoroState.formattedTime)
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundColor(viewModel.currentTheme.primaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
                
                // Progress indicator
                ProgressView(value: viewModel.pomodoroState.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: viewModel.currentTheme.accentColor.color(for: viewModel.pomodoroState.currentPhase)))
                
                // Phase indicator
                Text(viewModel.pomodoroState.currentPhase.rawValue.uppercased())
                    .font(.caption)
                    .foregroundColor(viewModel.currentTheme.secondaryTextColor.color(for: viewModel.pomodoroState.currentPhase))
            }
            
            // Ripple effect
            if rippleTrigger {
                RippleView(trigger: $rippleTrigger)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

---

## Advanced Features

### Custom Keyboard Behaviors

Override specific keyboard behaviors for your theme:

```swift
func customKeyboardBehavior(for keyCode: UInt16) -> KeyboardBehavior? {
    switch keyCode {
    case 46: // M key
        return .enhanced(
            action: {
                // Custom action for M key
                print("Custom M key behavior")
            },
            visualFeedback: "CUSTOM_MODE"
        )
    case 18: // 1 key
        return .disabled  // Disable this key for this theme
    default:
        return nil // Use default behavior
    }
}
```

### Window Background Types

Choose how your theme's background appears:

**Blur Background**
```swift
let windowBackgroundType: WindowBackgroundType = .blur
let windowBackgroundColor: Color = .clear
```

**Solid Background**
```swift
let windowBackgroundType: WindowBackgroundType = .solid
let windowBackgroundColor: Color = .black
```

**Gradient Background** (Future feature)
```swift
let windowBackgroundType: WindowBackgroundType = .gradient
let windowBackgroundColor: Color = .blue  // Base color for gradient
```

### Animation Integration

Integrate with the ripple animation system:

```swift
@ViewBuilder
func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> some View {
    ZStack {
        // Your theme content
        MyThemeContentView()
        
        // Ripple effect integration
        RippleView(trigger: rippleTrigger)
            .opacity(rippleTrigger ? 1.0 : 0.0)
            .animation(.easeOut(duration: 1.0), value: rippleTrigger)
    }
}
```

### Font Customization

Customize the timer font for your theme:

```swift
// System fonts
let timerFont: Font = .system(size: 64, weight: .bold, design: .rounded)
let timerFont: Font = .system(size: 56, weight: .medium, design: .monospaced)

// Custom fonts (if added to app bundle)
let timerFont: Font = .custom("YourCustomFont-Bold", size: 64)

// Conditional fonts
let timerFont: Font = {
    if #available(macOS 13.0, *) {
        return .system(size: 64, weight: .bold, design: .rounded)
    } else {
        return .system(size: 64, weight: .bold)
    }
}()
```

### Performance Optimization

Optimize your theme for smooth performance:

```swift
struct MyOptimizedThemeView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @Binding var rippleTrigger: Bool
    
    // Cache expensive computations
    private var progressColor: Color {
        viewModel.currentTheme.accentColor.color(for: viewModel.pomodoroState.currentPhase)
    }
    
    var body: some View {
        // Use efficient view updates
        Text(viewModel.pomodoroState.formattedTime)
            .font(.system(size: 72, weight: .bold, design: .monospaced))
            .foregroundColor(progressColor)
            .id("timer-\(viewModel.currentTheme.id)")  // Explicit identity for theme changes
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentTheme.id)
    }
}
```

---

## Testing & Debugging

### Theme Testing Checklist

**Basic Functionality**
- [ ] Theme appears in picker
- [ ] Theme switches correctly
- [ ] All colors update properly
- [ ] Fonts render correctly
- [ ] Animations work smoothly

**Phase Transitions**
- [ ] Work → Short Break color transition
- [ ] Short Break → Work color transition  
- [ ] Work → Long Break color transition
- [ ] Long Break → Work color transition

**Interaction Testing**
- [ ] Buttons work (if applicable)
- [ ] Keyboard shortcuts work
- [ ] Custom behaviors work (if implemented)
- [ ] Hover effects work
- [ ] Ripple animations work

**Edge Cases**
- [ ] Theme works with paused timer
- [ ] Theme works with reset timer
- [ ] Theme works during phase transitions
- [ ] Theme works with accessibility features
- [ ] Theme works on different screen sizes

### Debug Logging

Add debug output to your theme:

```swift
struct DebugTheme: ThemeDefinition {
    let id = "debug-theme"
    // ... other properties
    
    func createExperience() -> AnyThemeExperience {
        print("🎨 Creating experience for \(displayName)")
        return AnyThemeExperience(DebugThemeExperience())
    }
    
    static func register() {
        print("🎨 Registering \(self)")
        ThemeRegistry.shared.register(DebugTheme())
    }
}
```

### Registry Debugging

Check registry state:

```swift
// In your theme or during development
ThemeRegistry.shared.printRegisteredThemes()
print("Registry valid: \(ThemeRegistry.shared.validateRegistry())")
```

### Common Issues and Solutions

**Theme doesn't appear in picker**
- Check registration in `ThemeRegistrationHelper`
- Verify unique theme ID
- Check for compilation errors

**Colors don't update**
- Ensure using `.color(for: phase)` method
- Check `ThemeColor` definition
- Verify view updates with `@EnvironmentObject`

**Animations don't work**
- Check ripple trigger binding
- Verify animation modifiers
- Test with different themes

**Performance issues**
- Use explicit view identity (`.id()`)
- Cache expensive computations
- Minimize view updates

---

## Distribution & Import

### Internal Distribution

**For Built-in Themes**
1. Add theme file to Xcode project
2. Register in `ThemeRegistrationHelper`
3. Build and distribute app

### External Theme System (Future)

The current architecture is designed to support external themes:

**Potential Plugin System**
```swift
// Future: Load themes from external bundles
extension ThemeRegistry {
    func loadExternalThemes(from directory: URL) {
        // Load .themebundle files
        // Validate and register themes
        // Handle conflicts and versioning
    }
}
```

**Theme Bundle Structure**
```
MyTheme.themebundle/
├── Contents/
│   ├── Info.plist           # Theme metadata
│   ├── MacOS/
│   │   └── MyTheme          # Compiled theme code
│   └── Resources/
│       ├── icon.png         # Theme icon
│       └── preview.png      # Theme preview
```

### Sharing Themes

**Current Method (Source Code)**
1. Share theme file (.swift)
2. Instructions for integration
3. Registration steps

**Future Method (Bundles)**
1. Export as .themebundle
2. Double-click to install
3. Automatic registration

---

## Best Practices

### Design Guidelines

**Visual Hierarchy**
- Primary elements: Timer display, current phase
- Secondary elements: Session info, progress indicators
- Tertiary elements: Controls, metadata

**Color Psychology**
- Work sessions: Energizing colors (green, blue)
- Short breaks: Calming colors (blue, teal)
- Long breaks: Restful colors (purple, deep blue)

**Accessibility**
- Maintain 4.5:1 contrast ratio minimum
- Support system color preferences
- Test with VoiceOver and accessibility features

### Performance Guidelines

**Efficient Updates**
```swift
// Good: Specific updates
.foregroundColor(theme.primaryTextColor.color(for: currentPhase))

// Bad: Full view recreation
.foregroundColor(determineColorForCurrentState())
```

**Animation Performance**
```swift
// Good: Hardware-accelerated animations
.scaleEffect(isAnimating ? 1.1 : 1.0)
.animation(.spring(), value: isAnimating)

// Bad: CPU-intensive animations
.rotationEffect(.degrees(continuousRotation))
```

**Memory Management**
```swift
// Good: Lazy initialization
private var expensiveView: some View {
    createComplexVisualization()
}

// Bad: Eager computation
private let allViews = (0..<1000).map { createView($0) }
```

### Code Organization

**File Structure**
```swift
// Single file per theme
struct MyTheme: ThemeDefinition {
    // Theme definition
}

struct MyThemeExperience: ThemeExperience {
    // Theme behavior
}

// Optional: Custom views
struct MyThemeView: View {
    // Custom UI
}

// Optional: Helper components
struct MyThemeProgressView: View {
    // Reusable components
}
```

**Naming Conventions**
- Theme structs: `[Name]Theme` (e.g., `MinimalTheme`)
- Experience structs: `[Name]Experience` (e.g., `MinimalExperience`)
- View structs: `[Name]ThemeView` (e.g., `MinimalThemeView`)
- Theme IDs: kebab-case (e.g., `"minimal"`, `"my-awesome-theme"`)

### Testing Strategy

**Unit Testing Themes**
```swift
import XCTest
@testable import PomodoroTimer

class MyThemeTests: XCTestCase {
    func testThemeRegistration() {
        let initialCount = ThemeRegistry.shared.themeCount
        MyTheme.register()
        XCTAssertEqual(ThemeRegistry.shared.themeCount, initialCount + 1)
    }
    
    func testThemeProperties() {
        let theme = MyTheme()
        XCTAssertEqual(theme.id, "my-theme")
        XCTAssertEqual(theme.displayName, "My Theme")
        XCTAssertFalse(theme.displayName.isEmpty)
    }
    
    func testColorConsistency() {
        let theme = MyTheme()
        let workColor = theme.accentColor.color(for: .work)
        let breakColor = theme.accentColor.color(for: .shortBreak)
        // Assert color relationships
        XCTAssertNotEqual(workColor, breakColor)
    }
}
```

**Integration Testing**
- Test theme switching in running app
- Verify UI updates across all phases
- Test with real timer cycles

---

## API Reference

### ThemeDefinition Protocol

```swift
protocol ThemeDefinition: Identifiable, Equatable {
    // Identity
    var id: String { get }
    var displayName: String { get }
    var description: String { get }
    var icon: String { get }
    
    // Colors
    var accentColor: ThemeColor { get }
    var backgroundColor: Color { get }
    var primaryTextColor: ThemeColor { get }
    var secondaryTextColor: ThemeColor { get }
    var timerFont: Font { get }
    
    // Button colors
    var primaryButtonColor: ThemeColor { get }
    var secondaryButtonColor: ThemeColor { get }
    var buttonTextColor: ThemeColor { get }
    var buttonHoverColor: ThemeColor { get }
    var buttonShadowColor: Color { get }
    
    // Window properties
    var windowBackgroundType: WindowBackgroundType { get }
    var windowBackgroundColor: Color { get }
    var preferredWindowSize: CGSize { get }
    
    // Factory methods
    func createExperience() -> AnyThemeExperience
    static func register()
}
```

### ThemeExperience Protocol

```swift
protocol ThemeExperience {
    associatedtype ContentView: View
    associatedtype ControlsView: View
    
    // Behavior
    var allowsVisualControls: Bool { get }
    var preferredInteractionModel: InteractionModel { get }
    var requiresKeyboardFocus: Bool { get }
    
    // View factories
    func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> ContentView
    func makeControlsView(viewModel: TimerViewModel) -> ControlsView
    
    // Customization
    func customKeyboardBehavior(for keyCode: UInt16) -> KeyboardBehavior?
}
```

### ThemeRegistry API

```swift
class ThemeRegistry: ObservableObject {
    static let shared: ThemeRegistry
    
    // Properties
    var availableThemes: [AnyTheme] { get }
    var themeCount: Int { get }
    var defaultTheme: AnyTheme? { get }
    
    // Registration
    func register<T: ThemeDefinition>(_ theme: T)
    func unregister(themeWithId id: String) -> Bool
    
    // Discovery
    func theme(withId id: String) -> AnyTheme?
    func theme(withDisplayName displayName: String) -> AnyTheme?
    
    // Utilities
    func printRegisteredThemes()
    func validateRegistry() -> Bool
    func clearAll()
}
```

### Helper Components

**StandardControlsView**
```swift
struct StandardControlsView: View {
    let viewModel: TimerViewModel
    // Provides: Play/pause, skip, reset, sound test buttons
}
```

**ThemeColor Utilities**
```swift
enum ThemeColor: Equatable {
    case triPhase(work: Color, shortBreak: Color, longBreak: Color)
    
    func color(for phase: PomodoroPhase) -> Color
}
```

**Interaction Models**
```swift
enum InteractionModel {
    case graphical      // Traditional GUI
    case commandLine    // Keyboard-only
    case hybrid         // Both GUI and keyboard
    case minimal        // Simplified interaction
}
```

**Keyboard Behaviors**
```swift
enum KeyboardBehavior {
    case `default`                          // Standard behavior
    case custom(action: () -> Void)         // Custom action
    case disabled                           // Disable key
    case enhanced(action: () -> Void,       // Enhanced with feedback
                 visualFeedback: String)
}
```

---

## Troubleshooting

### Common Errors

**"Cannot find type 'Theme' in scope"**
- You're using the old Theme system
- Import the new ThemeDefinition protocol
- Update to use AnyTheme instead

**"Theme not appearing in picker"**
- Check theme registration in ThemeRegistrationHelper
- Verify unique theme ID
- Check for compilation errors in theme file

**"Colors not updating during phase transitions"**
- Use `.color(for: phase)` method on ThemeColor
- Ensure @EnvironmentObject is properly connected
- Check that view updates are triggered

**"Build fails after adding theme"**
- Check all required protocol methods are implemented
- Verify import statements
- Check for syntax errors in theme definition

### Performance Issues

**Slow theme switching**
- Add explicit view identity with `.id()`
- Cache expensive color computations
- Minimize view recreation

**High CPU usage**
- Check for infinite animation loops
- Reduce complex view calculations
- Use hardware-accelerated animations

### Registry Issues

**Duplicate theme IDs**
- Ensure unique theme IDs across all themes
- Use descriptive, collision-resistant names
- Check registry validation: `ThemeRegistry.shared.validateRegistry()`

**Theme not loading on startup**
- Verify registration in ThemeRegistrationHelper
- Check app delegate initialization order
- Add debug logging to track registration

### Debug Tools

**Registry Debug Commands**
```swift
// Print all registered themes
ThemeRegistry.shared.printRegisteredThemes()

// Validate registry state
let isValid = ThemeRegistry.shared.validateRegistry()
print("Registry valid: \(isValid)")

// Get theme count
print("Total themes: \(ThemeRegistry.shared.themeCount)")
```

**Theme Debug Logging**
```swift
// Add to your theme's register() method
static func register() {
    print("🎨 Registering \(self)")
    ThemeRegistry.shared.register(YourTheme())
    print("🎨 Registration complete, total themes: \(ThemeRegistry.shared.themeCount)")
}
```

### Getting Help

1. **Check Existing Themes**: Look at MinimalTheme.swift, GridTheme.swift, TerminalTheme.swift for examples
2. **Console Logging**: Enable debug logging for registration and color updates
3. **Registry Validation**: Use built-in validation methods
4. **Build Clean**: Try "Product → Clean Build Folder" if issues persist
5. **Documentation**: Refer to CLAUDE.md for architectural context

---

## Conclusion

The Pomodoro Timer's extensible theme system provides a powerful foundation for creating custom visual experiences. Whether you're creating a simple color variation or a completely new interaction paradigm, the protocol-oriented architecture ensures type safety while maximizing flexibility.

Key takeaways:
- **One file per theme** - complete self-contained implementations
- **Automatic discovery** - no manual UI updates needed
- **Type safety preserved** - full SwiftUI compile-time checking
- **Performance optimized** - efficient theme switching and updates
- **Future-ready** - architecture supports external theme plugins

Happy theming! 🎨

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Compatibility**: macOS 13.0+, SwiftUI 4.0+