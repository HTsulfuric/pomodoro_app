import SwiftUI

// MARK: - Core Protocol

/// Defines the complete behavioral and visual experience for a theme
/// Each theme implements this protocol to provide its unique interaction paradigm
protocol ThemeExperience {
    associatedtype ContentView: View
    associatedtype ControlsView: View
    
    // MARK: - Behavioral Characteristics
    
    /// Whether this theme displays visual control buttons
    var allowsVisualControls: Bool { get }
    
    /// The preferred interaction model for this theme
    var preferredInteractionModel: InteractionModel { get }
    
    /// Whether this theme requires keyboard focus for optimal experience
    var requiresKeyboardFocus: Bool { get }
    
    // MARK: - View Factories
    
    /// Creates the main content view for this theme (timer display, animations, etc.)
    @ViewBuilder
    func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> ContentView
    
    /// Creates the control view for this theme (buttons, input fields, etc.)
    @ViewBuilder
    func makeControlsView(viewModel: TimerViewModel) -> ControlsView
    
    // MARK: - Advanced Keyboard Customization
    
    /// Provides custom keyboard behavior for specific keys
    /// Returns nil to use default behavior
    func customKeyboardBehavior(for keyCode: UInt16) -> KeyboardBehavior?
}

// MARK: - Supporting Types

/// Defines the interaction paradigm of a theme
enum InteractionModel {
    case graphical      /// Traditional GUI with visual buttons
    case commandLine    /// Terminal-style, keyboard-only interaction
    case hybrid         /// Optimized for both GUI and keyboard use
    case minimal        /// Simplified interaction with minimal visual elements
}

/// Defines custom keyboard behavior for theme-specific actions
enum KeyboardBehavior {
    case `default`                          /// Use the standard keyboard handling
    case custom(action: () -> Void)         /// Execute a custom action
    case disabled                           /// Disable this key for this theme
    case enhanced(action: () -> Void,       /// Enhanced behavior with visual feedback
                 visualFeedback: String)
}

// MARK: - Default Implementations

extension ThemeExperience {
    /// Default implementation returns nil (use standard keyboard behavior)
    func customKeyboardBehavior(for keyCode: UInt16) -> KeyboardBehavior? {
        return nil
    }
    
    /// Default keyboard focus requirement based on interaction model
    var requiresKeyboardFocus: Bool {
        switch preferredInteractionModel {
        case .commandLine:
            return true
        case .graphical, .hybrid, .minimal:
            return false
        }
    }
}

// MARK: - Type-Erased Wrapper

/// Type-erased wrapper for ThemeExperience to enable runtime theme switching
/// while maintaining compile-time safety
struct AnyThemeExperience {
    // MARK: - Private Storage
    
    private let _allowsVisualControls: () -> Bool
    private let _preferredInteractionModel: () -> InteractionModel
    private let _requiresKeyboardFocus: () -> Bool
    private let _makeContentView: (TimerViewModel, Binding<Bool>) -> AnyView
    private let _makeControlsView: (TimerViewModel) -> AnyView
    private let _customKeyboardBehavior: (UInt16) -> KeyboardBehavior?
    
    // MARK: - Initialization
    
    /// Creates a type-erased wrapper around any ThemeExperience
    init<T: ThemeExperience>(_ experience: T) {
        _allowsVisualControls = { experience.allowsVisualControls }
        _preferredInteractionModel = { experience.preferredInteractionModel }
        _requiresKeyboardFocus = { experience.requiresKeyboardFocus }
        
        _makeContentView = { viewModel, rippleTrigger in
            AnyView(experience.makeContentView(viewModel: viewModel, rippleTrigger: rippleTrigger))
        }
        
        _makeControlsView = { viewModel in
            AnyView(experience.makeControlsView(viewModel: viewModel))
        }
        
        _customKeyboardBehavior = { keyCode in
            experience.customKeyboardBehavior(for: keyCode)
        }
    }
    
    // MARK: - Public Interface
    
    /// Whether this theme displays visual control buttons
    var allowsVisualControls: Bool {
        _allowsVisualControls()
    }
    
    /// The preferred interaction model for this theme
    var preferredInteractionModel: InteractionModel {
        _preferredInteractionModel()
    }
    
    /// Whether this theme requires keyboard focus for optimal experience
    var requiresKeyboardFocus: Bool {
        _requiresKeyboardFocus()
    }
    
    /// Creates the main content view for this theme
    func makeContentView(viewModel: TimerViewModel, rippleTrigger: Binding<Bool>) -> AnyView {
        _makeContentView(viewModel, rippleTrigger)
    }
    
    /// Creates the control view for this theme
    func makeControlsView(viewModel: TimerViewModel) -> AnyView {
        _makeControlsView(viewModel)
    }
    
    /// Provides custom keyboard behavior for specific keys
    func customKeyboardBehavior(for keyCode: UInt16) -> KeyboardBehavior? {
        _customKeyboardBehavior(keyCode)
    }
}