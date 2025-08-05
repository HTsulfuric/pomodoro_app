import AppKit

/// Custom NSPanel for Alfred-style overlay behavior that doesn't steal application focus
class OverlayPanel: NSPanel {
    init(contentRect: NSRect) {
        // Initialize with .borderless and .nonactivatingPanel - this is the key to Alfred-like behavior
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false,
        )

        setupAlfredStyleBehavior()
    }

    private func setupAlfredStyleBehavior() {
        // CRITICAL: Float above other windows
        level = .floating

        // Allow transparent background and custom shapes
        isOpaque = false
        backgroundColor = .clear

        // Add shadow for depth (like Alfred)
        hasShadow = true

        // Configure collection behavior for Alfred-like experience
        collectionBehavior = [
            .canJoinAllSpaces, // Appears on whichever Space is active
            .transient, // Doesn't show up in Mission Control/Dock
            .fullScreenAuxiliary, // Works even in full-screen apps (crucial!)
        ]

        // Keep panel in memory when hidden
        isReleasedWhenClosed = false

        Logger.overlay("OverlayPanel configured for Alfred-style behavior")
    }

    // ESSENTIAL: Allow panel to become key window for keyboard input
    // without making the entire application active
    override var canBecomeKey: Bool {
        true
    }

    // Optional: Ensure we can accept first responder status
    override var canBecomeMain: Bool {
        false // We don't want to be the main window
    }
}
