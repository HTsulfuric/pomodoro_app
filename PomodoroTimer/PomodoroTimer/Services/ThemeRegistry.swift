import Foundation
import SwiftUI

/// Singleton registry for managing and discovering themes dynamically
class ThemeRegistry: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = ThemeRegistry()
    
    // MARK: - Private Properties
    
    @Published private var registeredThemes: [AnyTheme] = []
    private let registrationQueue = DispatchQueue(label: "theme.registry", qos: .userInitiated)
    
    // MARK: - Initialization
    
    private init() {
        // Private initializer for singleton pattern
        setupDefaultThemes()
    }
    
    // MARK: - Public Interface
    
    /// All available themes in the registry
    var availableThemes: [AnyTheme] {
        registrationQueue.sync {
            return registeredThemes
        }
    }
    
    /// Total number of registered themes
    var themeCount: Int {
        registrationQueue.sync {
            return registeredThemes.count
        }
    }
    
    /// Find a theme by its ID
    /// - Parameter id: The unique identifier for the theme
    /// - Returns: The theme if found, nil otherwise
    func theme(withId id: String) -> AnyTheme? {
        return registrationQueue.sync {
            return registeredThemes.first { $0.id == id }
        }
    }
    
    /// Find a theme by its display name
    /// - Parameter displayName: The display name of the theme
    /// - Returns: The theme if found, nil otherwise
    func theme(withDisplayName displayName: String) -> AnyTheme? {
        return registrationQueue.sync {
            return registeredThemes.first { $0.displayName == displayName }
        }
    }
    
    /// Register a new theme with the registry
    /// - Parameter theme: The theme to register
    /// - Note: Duplicate themes (same ID) will not be registered
    func register<T: ThemeDefinition>(_ theme: T) {
        let anyTheme = AnyTheme(theme)
        
        registrationQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Check for duplicates
            if !self.registeredThemes.contains(where: { $0.id == anyTheme.id }) {
                self.registeredThemes.append(anyTheme)
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
                
            } else {
                Logger.warning("Theme with ID '\(anyTheme.id)' already registered", category: .themes)
            }
        }
    }
    
    /// Unregister a theme from the registry
    /// - Parameter id: The ID of the theme to remove
    /// - Returns: True if the theme was found and removed, false otherwise
    @discardableResult
    func unregister(themeWithId id: String) -> Bool {
        return registrationQueue.sync {
            if let index = registeredThemes.firstIndex(where: { $0.id == id }) {
                let removedTheme = registeredThemes.remove(at: index)
                
                DispatchQueue.main.async { [weak self] in
                    self?.objectWillChange.send()
                }
                
                return true
            }
            return false
        }
    }
    
    /// Get the default theme (first registered theme, typically minimal)
    var defaultTheme: AnyTheme? {
        return availableThemes.first
    }
    
    /// Clear all registered themes (useful for testing)
    func clearAll() {
        registrationQueue.async { [weak self] in
            guard let self = self else { return }
            
            let count = self.registeredThemes.count
            self.registeredThemes.removeAll()
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            
        }
    }
    
    // MARK: - Private Methods
    
    /// Sets up default themes during initialization
    /// This will be replaced by individual theme registration calls
    private func setupDefaultThemes() {
        // Themes will register themselves when their files are loaded
        // This method exists for backward compatibility during migration
    }
    
    // MARK: - Debug Support
    
    /// Print all registered themes (debug utility)
    func printRegisteredThemes() {
        let themes = availableThemes
        print("Registered Themes (\(themes.count)):")
        for (index, theme) in themes.enumerated() {
            print("  \(index + 1). \(theme.displayName) (id: \(theme.id))")
        }
    }
    
    /// Validate registry state (debug utility)
    func validateRegistry() -> Bool {
        let themes = availableThemes
        let uniqueIds = Set(themes.map { $0.id })
        let uniqueDisplayNames = Set(themes.map { $0.displayName })
        
        let hasUniqueIds = uniqueIds.count == themes.count
        let hasUniqueDisplayNames = uniqueDisplayNames.count == themes.count
        
        if !hasUniqueIds {
            print("Error: Registry validation failed - Duplicate theme IDs detected")
        }
        
        if !hasUniqueDisplayNames {
            print("Error: Registry validation failed - Duplicate display names detected")
        }
        
        return hasUniqueIds && hasUniqueDisplayNames
    }
}

// MARK: - Registry Integration Helper

/// Helper for automatic theme registration during app startup
struct ThemeRegistrationHelper {
    
    /// Register all built-in themes
    /// This should be called during app initialization
    static func registerBuiltInThemes() {
        // Individual theme files will call their register() methods
        // This ensures themes are loaded and registered automatically
        MinimalTheme.register()
        GridTheme.register()
        TerminalTheme.register()
        AuraMinimalistTheme.register()
        
        
        // Validate the registry after registration
        if ThemeRegistry.shared.validateRegistry() {
        }
    }
}