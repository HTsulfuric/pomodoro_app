import Foundation
import SwiftUI

// MARK: - ThemeController  
// Specialized controller for theme management and theme picker
// Handles: Theme selection, theme picker state, theme persistence

class ThemeController {
    // MARK: - Delegate Communication
    weak var delegate: ThemeControllerDelegate?
    
    // MARK: - Private Properties (Moved from TimerViewModel)
    private var currentTheme: AnyTheme
    private var highlightedTheme: AnyTheme?
    private var highlightedThemeIndex: Int = 0
    private var originalTheme: AnyTheme?
    private var isThemePickerPresented: Bool = false
    
    init() {
        // Load saved theme or use default
        if let savedThemeId = UserDefaults.standard.string(forKey: "selectedTheme"),
           let savedTheme = ThemeRegistry.shared.theme(withId: savedThemeId) {
            self.currentTheme = savedTheme
        } else {
            // Use default theme from registry or fallback to minimal
            if let defaultTheme = ThemeRegistry.shared.defaultTheme {
                self.currentTheme = defaultTheme
            } else {
                self.currentTheme = AnyTheme(MinimalTheme())
            }
        }
        
        // Note: Delegate will be set by AppCoordinator after initialization
        // Initial theme will be communicated via getCurrentTheme() method
    }
    
    // MARK: - Theme Access
    func getCurrentTheme() -> AnyTheme {
        return currentTheme
    }
    
    // MARK: - Public Interface (Moved from TimerViewModel)
    
    func setTheme(_ newTheme: AnyTheme) {
        currentTheme = newTheme
        UserDefaults.standard.set(newTheme.id, forKey: "selectedTheme")
        
        // Notify delegate of theme change
        delegate?.themeDidChange(currentTheme)
        
        // Note: Window resize removed - all themes now use full screen
    }
    
    func toggleThemePicker() {
        if isThemePickerPresented {
            cancelThemeSelection()
        } else {
            presentThemePicker()
        }
    }
    
    func presentThemePicker() {
        originalTheme = currentTheme
        isThemePickerPresented = true
        
        // Notify delegate of picker presentation
        delegate?.themePickerDidChangePresentation(true)
        
        // Initialize highlighted theme to current theme
        if let currentIndex = ThemeRegistry.shared.availableThemes.firstIndex(where: { $0.id == currentTheme.id }) {
            setHighlightedThemeIndex(currentIndex)
        }
    }
    
    func selectNextTheme() {
        let themes = ThemeRegistry.shared.availableThemes
        guard !themes.isEmpty else { return }
        
        highlightedThemeIndex = (highlightedThemeIndex + 1) % themes.count
        updateHighlightedTheme()
    }
    
    func selectPreviousTheme() {
        let themes = ThemeRegistry.shared.availableThemes
        guard !themes.isEmpty else { return }
        
        highlightedThemeIndex = highlightedThemeIndex > 0 ? highlightedThemeIndex - 1 : themes.count - 1
        updateHighlightedTheme()
    }
    
    func setHighlightedThemeIndex(_ index: Int) {
        let themes = ThemeRegistry.shared.availableThemes
        guard index >= 0 && index < themes.count else { return }
        
        highlightedThemeIndex = index
        updateHighlightedTheme()
    }
    
    func confirmThemeSelection() {
        if let highlightedTheme = highlightedTheme {
            setTheme(highlightedTheme)
        }
        isThemePickerPresented = false
        originalTheme = nil
        
        // Notify delegate of picker dismissal
        delegate?.themePickerDidChangePresentation(false)
    }
    
    func cancelThemeSelection() {
        if let originalTheme = originalTheme {
            currentTheme = originalTheme
            // Notify delegate of theme reversion
            delegate?.themeDidChange(currentTheme)
        }
        isThemePickerPresented = false
        highlightedTheme = nil
        originalTheme = nil
        
        // Notify delegate of picker dismissal and highlight clear
        delegate?.themePickerDidChangePresentation(false)
        delegate?.themePickerDidUpdateHighlight(nil, index: 0)
    }
    
    // MARK: - Private Helper Methods (Moved from TimerViewModel)
    
    private func updateHighlightedTheme() {
        let themes = ThemeRegistry.shared.availableThemes
        guard highlightedThemeIndex >= 0 && highlightedThemeIndex < themes.count else { return }
        
        highlightedTheme = themes[highlightedThemeIndex]
        
        // Apply live preview with safe optional binding
        if let theme = highlightedTheme {
            currentTheme = theme
            // Notify delegate of live preview theme change
            delegate?.themeDidChange(currentTheme)
        }
        
        // Notify delegate of highlight update
        delegate?.themePickerDidUpdateHighlight(highlightedTheme, index: highlightedThemeIndex)
    }
}