import SwiftUI

struct CircleHoverButtonStyle: ButtonStyle {
    @State private var isHovering = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : (isHovering ? 1.05 : 1.0))
            .shadow(
                color: .black.opacity(isHovering ? 0.4 : 0.2),
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