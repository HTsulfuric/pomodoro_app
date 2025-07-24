import SwiftUI

struct CircleHoverButtonStyle: ButtonStyle {
    let theme: Theme?
    
    @State private var isHovering = false
    
    // Default initializer for backward compatibility
    init() {
        self.theme = nil
    }
    
    // Theme-aware initializer
    init(theme: Theme) {
        self.theme = theme
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let shadowColor = theme?.buttonShadowColor ?? .black
        
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : (isHovering ? 1.05 : 1.0))
            .shadow(
                color: shadowColor.opacity(isHovering ? 0.4 : 0.2),
                radius: isHovering ? 6 : 3,
                x: 0,
                y: isHovering ? 3 : 2
            )
            .animation(.easeInOut(duration: 0.2), value: isHovering)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}