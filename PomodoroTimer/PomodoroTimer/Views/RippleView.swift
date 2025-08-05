import SwiftUI

/// A single self-contained ripple circle that manages its own animation state
struct RippleCircle: View {
    let trigger: Bool
    let delay: Double
    let rippleColor: Color

    @State private var scale: CGFloat = 0.0
    @State private var opacity: Double = 1.0

    private let animationDuration: Double = 1.8

    var body: some View {
        Circle()
            .stroke(rippleColor.opacity(0.8), lineWidth: 3)
            .frame(width: 60, height: 60)
            .scaleEffect(scale)
            .opacity(opacity)
            .onChange(of: trigger) { _, _ in
                startSelfContainedAnimation()
            }
    }

    private func startSelfContainedAnimation() {
        // Step 1: Immediately reset to starting state
        scale = 0.0
        opacity = 1.0

        // Step 2: Start animation after stagger delay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeOut(duration: animationDuration)) {
                scale = 2.5
                opacity = 0.0
            }
        }
    }
}

/// A zen-like ripple animation that creates expanding water-like circles from the center
/// Triggered by a boolean toggle, creating a "stone dropped in water" effect
struct RippleView: View {
    /// An external trigger to start the animation. The animation runs whenever this value changes.
    let trigger: Bool

    @EnvironmentObject var viewModel: AppCoordinator

    private let rippleCount = 4
    private let staggerDelay: Double = 0.3

    var body: some View {
        ZStack {
            // Create staggered ripple circles - each manages its own state
            ForEach(0 ..< rippleCount, id: \.self) { index in
                RippleCircle(
                    trigger: trigger,
                    delay: Double(index) * staggerDelay,
                    rippleColor: viewModel.currentTheme.accentColor.color(for: viewModel.pomodoroState.currentPhase),
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow full expansion
        .allowsHitTesting(false) // Don't interfere with UI interactions
    }
}

#Preview {
    @Previewable @State var trigger = false

    ZStack {
        Color.black.opacity(0.8)
        RippleView(trigger: trigger)
            .environmentObject(AppCoordinator())

        VStack {
            Spacer()
            Button("Trigger Ripple") {
                trigger.toggle()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue.opacity(0.6))
            .cornerRadius(8)
        }
    }
    .frame(width: 400, height: 400)
}
