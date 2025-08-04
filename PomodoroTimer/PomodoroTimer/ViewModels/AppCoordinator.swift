import Foundation
import SwiftUI

// MARK: - Delegate Protocols for Controller Communication

protocol TimerControllerDelegate: AnyObject {
    func timerDidUpdateState(_ state: PomodoroState)
    func timerDidUpdateSessionCount(_ count: Int)
}

protocol ThemeControllerDelegate: AnyObject {
    func themeDidChange(_ theme: AnyTheme)
    func themePickerDidChangePresentation(_ isPresented: Bool)
    func themePickerDidUpdateHighlight(_ theme: AnyTheme?, index: Int)
}

protocol IntegrationControllerDelegate: AnyObject {
    func integrationDidUpdateSessionCount(_ count: Int)
}

// MARK: - AppCoordinator
// Central coordinator that owns @Published properties for Views
// and coordinates communication between specialized controllers

@MainActor
class AppCoordinator: ObservableObject {
    // MARK: - Published Properties for Views
    // These are the exact properties that Views currently expect from TimerViewModel
    
    @Published var pomodoroState = PomodoroState()
    @Published var totalSessionsToday: Int = 0
    @Published var currentTheme: AnyTheme = ThemeRegistry.shared.defaultTheme ?? AnyTheme(MinimalTheme())
    @Published var isThemePickerPresented: Bool = false
    @Published var highlightedTheme: AnyTheme?
    @Published var highlightedThemeIndex: Int = 0
    
    // MARK: - Controller Instances
    private let timerController: TimerController
    private let themeController: ThemeController  
    private let integrationController: IntegrationController
    
    init() {
        // Initialize controllers
        self.timerController = TimerController()
        self.themeController = ThemeController()
        self.integrationController = IntegrationController()
        
        // Wire up delegate connections
        timerController.delegate = self
        themeController.delegate = self
        integrationController.delegate = self
    }
    
    // MARK: - Public Interface for Views
    // These methods delegate to the appropriate controllers
    
    func toggleTimer() {
        timerController.toggleTimer()
    }
    
    func startTimer() {
        timerController.startTimer()
    }
    
    func pauseTimer() {
        timerController.pauseTimer()
    }
    
    func resetTimer() {
        timerController.resetTimer()
    }
    
    func skipPhase() {
        timerController.skipPhase()
    }
    
    func setTheme(_ theme: AnyTheme) {
        themeController.setTheme(theme)
    }
    
    func toggleThemePicker() {
        themeController.toggleThemePicker()
    }
    
    func presentThemePicker() {
        themeController.presentThemePicker()
    }
    
    func selectNextTheme() {
        themeController.selectNextTheme()
    }
    
    func selectPreviousTheme() {
        themeController.selectPreviousTheme()
    }
    
    func setHighlightedThemeIndex(_ index: Int) {
        themeController.setHighlightedThemeIndex(index)
    }
    
    func confirmThemeSelection() {
        themeController.confirmThemeSelection()
    }
    
    func cancelThemeSelection() {
        themeController.cancelThemeSelection()
    }
}

// MARK: - Delegate Conformances

extension AppCoordinator: TimerControllerDelegate {
    func timerDidUpdateState(_ state: PomodoroState) {
        pomodoroState = state
    }
    
    func timerDidUpdateSessionCount(_ count: Int) {
        totalSessionsToday = count
    }
}

extension AppCoordinator: ThemeControllerDelegate {
    func themeDidChange(_ theme: AnyTheme) {
        currentTheme = theme
    }
    
    func themePickerDidChangePresentation(_ isPresented: Bool) {
        isThemePickerPresented = isPresented
    }
    
    func themePickerDidUpdateHighlight(_ theme: AnyTheme?, index: Int) {
        highlightedTheme = theme
        highlightedThemeIndex = index
    }
}

extension AppCoordinator: IntegrationControllerDelegate {
    func integrationDidUpdateSessionCount(_ count: Int) {
        totalSessionsToday = count
    }
}