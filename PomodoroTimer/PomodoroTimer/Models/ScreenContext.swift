import AppKit
import Combine
import SwiftUI

/// Observable screen context that provides dynamic sizing information for themes
/// Updates automatically when the overlay moves between different monitors
class ScreenContext: ObservableObject {
    // MARK: - Published Properties

    /// Current screen that the overlay is displayed on
    @Published var currentScreen: NSScreen

    /// Current screen frame for calculations
    @Published var screenFrame: CGRect

    /// Screen identifier for detecting changes
    @Published private(set) var screenIdentifier: String

    // MARK: - Initialization

    init() {
        let screen = NSScreen.main ?? NSScreen.screens.first ?? NSScreen()
        currentScreen = screen
        screenFrame = screen.frame
        screenIdentifier = (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as AnyObject?)?.description ?? "unknown"

        Logger.screen("🖥️ ScreenContext initialized with screen: \(Int(screenFrame.width))×\(Int(screenFrame.height))")
    }

    // MARK: - Screen Updates

    /// Update the current screen information
    /// - Parameter screen: The new screen to use for calculations
    func updateScreen(_ screen: NSScreen) {
        let newIdentifier = (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as AnyObject?)?.description ?? "unknown"

        // Only update if screen actually changed
        guard newIdentifier != screenIdentifier else {
            Logger.screen("🖥️ ScreenContext: Same screen, no update needed")
            return
        }

        Logger.screen("🖥️ ScreenContext: Updating from \(Int(screenFrame.width))×\(Int(screenFrame.height)) to \(Int(screen.frame.width))×\(Int(screen.frame.height))")

        // Update published properties (will trigger SwiftUI re-renders)
        currentScreen = screen
        screenFrame = screen.frame
        screenIdentifier = newIdentifier

        Logger.screen("🖥️ ScreenContext: Screen update complete - themes will resize")
    }

    // MARK: - Screen Classification

    /// Current screen category based on dimensions
    var screenCategory: ScreenCategory {
        let width = screenFrame.width
        let aspectRatio = screenFrame.width / screenFrame.height

        // Ultra-wide detection: very wide aspect ratio or very wide resolution
        if aspectRatio > 2.5 || width > 3840 {
            return .ultraWide
        }

        // Size-based classification
        switch width {
        case ..<1600:
            return .small
        case 1600 ..< 2560:
            return .medium
        case 2560 ..< 3840:
            return .large
        default:
            return .ultraWide
        }
    }

    /// Current screen aspect ratio (width/height)
    var aspectRatio: CGFloat {
        screenFrame.width / screenFrame.height
    }

    // MARK: - Proportional Sizing Helpers

    /// Scale a base size proportionally to current screen width with practical limits
    /// - Parameters:
    ///   - baseSize: Size designed for 1920px width screen
    ///   - minSize: Minimum allowed size
    ///   - maxSize: Maximum allowed size
    /// - Returns: Scaled size with bounds applied
    func scaledSize(
        _ baseSize: CGFloat,
        minSize: CGFloat? = nil,
        maxSize: CGFloat? = nil,
    ) -> CGFloat {
        let referenceWidth: CGFloat = 1920 // Base design width
        let scaleFactor = screenFrame.width / referenceWidth
        let scaledSize = baseSize * scaleFactor

        // Apply bounds if specified
        var result = scaledSize
        if let min = minSize {
            result = max(result, min)
        }
        if let max = maxSize {
            result = min(result, max)
        }

        return result
    }

    /// Calculate scaled font size with logarithmic scaling to prevent extreme sizes
    /// - Parameters:
    ///   - baseSize: Font size designed for 1920px width screen
    ///   - minSize: Minimum font size
    ///   - maxSize: Maximum font size
    /// - Returns: Scaled font size with bounds applied
    func scaledFont(
        baseSize: CGFloat,
        minSize: CGFloat? = nil,
        maxSize: CGFloat? = nil,
    ) -> CGFloat {
        let referenceWidth: CGFloat = 1920
        let scaleFactor = screenFrame.width / referenceWidth

        // Use logarithmic scaling for fonts to prevent extreme sizes
        let logScaleFactor = 1.0 + (log(scaleFactor) * 0.3)
        let scaledSize = baseSize * logScaleFactor

        // Apply bounds
        var result = scaledSize
        if let min = minSize {
            result = max(result, min)
        }
        if let max = maxSize {
            result = min(result, max)
        }

        return result
    }

    // MARK: - Theme-Specific Sizing

    /// Calculate appropriate timer circle size based on current screen
    /// Target: ~15% of screen width, bounded for usability
    var timerCircleSize: CGSize {
        let diameter = scaledSize(
            280, // Base size for 1920px screen
            minSize: 200, // Don't go smaller than 200px
            maxSize: 500, // Don't go larger than 500px
        )
        return CGSize(width: diameter, height: diameter)
    }

    /// Calculate appropriate content padding based on current screen
    /// Larger screens get more padding, but with diminishing returns
    var contentPadding: CGFloat {
        scaledSize(
            24, // Base padding for 1920px screen
            minSize: 16, // Minimum padding
            maxSize: 48, // Maximum padding
        )
    }

    /// Calculate spacing between UI elements
    /// Scales more conservatively than other elements
    var elementSpacing: CGFloat {
        scaledSize(
            20, // Base spacing for 1920px screen
            minSize: 12, // Minimum spacing
            maxSize: 32, // Maximum spacing
        )
    }

    /// Calculate grid square size for Grid theme
    /// Scales to maintain readable grid proportions
    var gridSquareSize: CGFloat {
        scaledSize(
            28, // Base square size for 1920px screen
            minSize: 20, // Minimum readable size
            maxSize: 48, // Maximum before looking too chunky
        )
    }

    /// Calculate grid spacing for Grid theme
    var gridSpacing: CGFloat {
        scaledSize(
            6, // Base spacing for 1920px screen
            minSize: 4, // Minimum spacing
            maxSize: 12, // Maximum spacing
        )
    }

    // MARK: - Minimal Theme Specs

    /// Get scaled dimensions for Minimal theme circular progress
    var minimalCircleSpecs: (diameter: CGFloat, lineWidth: CGFloat) {
        let diameter = timerCircleSize.width
        let lineWidth = scaledSize(
            12, // Base line width for 1920px screen
            minSize: 8, // Minimum line width
            maxSize: 18, // Maximum line width
        )
        return (diameter: diameter, lineWidth: lineWidth)
    }

    // MARK: - Terminal Theme Specs

    /// Get scaled font sizes for Terminal theme
    var terminalFontSizes: (timer: CGFloat, header: CGFloat, controls: CGFloat) {
        let timerFont = scaledFont(
            baseSize: 48, // Base timer font for 1920px screen
            minSize: 36,
            maxSize: 72,
        )
        let headerFont = scaledFont(
            baseSize: 14, // Base header font
            minSize: 11,
            maxSize: 18,
        )
        let controlsFont = scaledFont(
            baseSize: 12, // Base controls font
            minSize: 10,
            maxSize: 16,
        )
        return (timer: timerFont, header: headerFont, controls: controlsFont)
    }

    // MARK: - Debug Information

    /// Debug information about current screen setup
    var debugInfo: String {
        let size = screenFrame
        let category = screenCategory
        let aspectRatio = aspectRatio

        return """
        Screen: \(Int(size.width))×\(Int(size.height))
        Category: \(category.description)
        Aspect Ratio: \(String(format: "%.2f", aspectRatio))
        Timer Circle: \(Int(timerCircleSize.width))px
        Content Padding: \(Int(contentPadding))px
        Grid Square: \(Int(gridSquareSize))px
        """
    }
}

/// Screen size categories for adaptive theming
enum ScreenCategory: CaseIterable {
    case small // < 1600px width (laptops)
    case medium // 1600-2560px width (standard desktops)
    case large // 2560-3840px width (4K, large displays)
    case ultraWide // > 3840px width or aspect ratio > 2.5

    /// Human-readable description
    var description: String {
        switch self {
        case .small: "Small (< 1600px)"
        case .medium: "Medium (1600-2560px)"
        case .large: "Large (2560-3840px)"
        case .ultraWide: "Ultra-wide (> 3840px or wide aspect)"
        }
    }
}
