import SwiftUI

// MARK: - Aura Focus Indicator

/// Revolutionary focus awareness indicator that visualizes environmental focus state
/// This subtle indicator shows users when the system detects their attention patterns
struct AuraFocusIndicator: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @EnvironmentObject var screenContext: ScreenContext
    @StateObject private var focusManager = FocusAwarenessManager.shared
    @State private var pulseAnimation = false
    @State private var showFocusTooltip = false
    
    private var indicatorWidth: CGFloat {
        screenContext.scaledSize(200, minSize: 150, maxSize: 250)
    }
    
    private var indicatorHeight: CGFloat {
        screenContext.scaledSize(6, minSize: 4, maxSize: 8)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: indicatorHeight / 2)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: indicatorWidth, height: indicatorHeight)
                
                // Focus quality fill
                RoundedRectangle(cornerRadius: indicatorHeight / 2)
                    .fill(focusGradient)
                    .frame(
                        width: indicatorWidth * focusManager.getFocusQualityScore(),
                        height: indicatorHeight
                    )
                    .animation(.smooth(duration: 2.0), value: focusManager.getFocusQualityScore())
                
                // Revolutionary pulsing focus state indicator
                Circle()
                    .fill(focusStateColor)
                    .frame(width: indicatorHeight * 2, height: indicatorHeight * 2)
                    .position(
                        x: (indicatorWidth * focusManager.getFocusQualityScore()).clamped(
                            to: indicatorHeight...indicatorWidth - indicatorHeight
                        ),
                        y: indicatorHeight / 2
                    )
                    .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                    .opacity(pulseAnimation ? 0.7 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                    .onAppear {
                        pulseAnimation = true
                    }
                
                // Subtle distraction warning particles
                if focusManager.distractionLevel > 0.3 {
                    ForEach(0..<3, id: \.self) { index in
                        DistractionParticle(
                            delay: Double(index) * 0.3,
                            indicatorWidth: indicatorWidth,
                            indicatorHeight: indicatorHeight
                        )
                    }
                }
            }
            .frame(width: indicatorWidth, height: indicatorHeight * 3)
            .onTapGesture {
                withAnimation(.spring()) {
                    showFocusTooltip.toggle()
                }
            }
            .overlay(alignment: .top) {
                if showFocusTooltip {
                    FocusTooltip()
                        .environmentObject(focusManager)
                        .transition(.opacity.combined(with: .offset(y: -10)))
                }
            }
        }
        .frame(height: indicatorHeight * 3)
    }
    
    // MARK: - Focus Gradient
    
    private var focusGradient: LinearGradient {
        let qualityScore = focusManager.getFocusQualityScore()
        
        if qualityScore > 0.8 {
            // Deep focus: vibrant blue to cyan
            return LinearGradient(
                colors: [
                    Color(red: 74/255, green: 144/255, blue: 226/255),
                    Color(red: 129/255, green: 199/255, blue: 244/255)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else if qualityScore > 0.5 {
            // Moderate focus: balanced blue-green
            return LinearGradient(
                colors: [
                    Color(red: 80/255, green: 170/255, blue: 200/255),
                    Color(red: 120/255, green: 200/255, blue: 220/255)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            // Low focus: muted orange to red warning
            return LinearGradient(
                colors: [
                    Color(red: 245/255, green: 166/255, blue: 35/255),
                    Color(red: 255/255, green: 100/255, blue: 100/255)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    // MARK: - Focus State Color
    
    private var focusStateColor: Color {
        switch focusManager.focusState {
        case .deepFocus:
            return Color(red: 129/255, green: 199/255, blue: 244/255)
        case .focused:
            return Color(red: 80/255, green: 227/255, blue: 194/255)
        case .switching:
            return Color(red: 248/255, green: 221/255, blue: 170/255)
        case .distracted:
            return Color(red: 255/255, green: 150/255, blue: 100/255)
        case .chaotic:
            return Color(red: 255/255, green: 100/255, blue: 100/255)
        }
    }
}

// MARK: - Distraction Particle

/// Subtle particle that indicates distraction presence
struct DistractionParticle: View {
    let delay: Double
    let indicatorWidth: CGFloat
    let indicatorHeight: CGFloat
    
    @State private var animate = false
    @State private var opacity = 0.0
    
    var body: some View {
        Circle()
            .fill(Color.red.opacity(0.4))
            .frame(width: 3, height: 3)
            .position(
                x: animate ? indicatorWidth + 20 : -20,
                y: indicatorHeight / 2 + (animate ? CGFloat.random(in: -5...5) : 0)
            )
            .opacity(opacity)
            .onAppear {
                withAnimation(.linear(duration: 3.0).delay(delay).repeatForever(autoreverses: false)) {
                    animate = true
                }
                withAnimation(.easeIn(duration: 0.5).delay(delay)) {
                    opacity = 1.0
                }
                withAnimation(.easeOut(duration: 0.5).delay(delay + 2.5)) {
                    opacity = 0.0
                }
            }
    }
}

// MARK: - Focus Tooltip

/// Intelligent tooltip showing detailed focus analytics
struct FocusTooltip: View {
    @EnvironmentObject var focusManager: FocusAwarenessManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Current focus state
            HStack(spacing: 8) {
                Circle()
                    .fill(focusStateColor)
                    .frame(width: 8, height: 8)
                
                Text(focusStateDescription)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Focus quality
            HStack {
                Text("Focus Quality:")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("\(Int(focusManager.getFocusQualityScore() * 100))%")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Current app
            if !focusManager.currentApp.isEmpty {
                HStack {
                    Text("Current App:")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text(focusManager.currentApp)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }
            }
            
            // Distraction level
            if focusManager.distractionLevel > 0.1 {
                HStack {
                    Text("Distraction:")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(Int(focusManager.distractionLevel * 100))%")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.orange.opacity(0.9))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    private var focusStateColor: Color {
        switch focusManager.focusState {
        case .deepFocus:
            return Color.blue
        case .focused:
            return Color.green
        case .switching:
            return Color.yellow
        case .distracted:
            return Color.orange
        case .chaotic:
            return Color.red
        }
    }
    
    private var focusStateDescription: String {
        switch focusManager.focusState {
        case .deepFocus:
            return "Deep Focus"
        case .focused:
            return "Focused"
        case .switching:
            return "Task Switching"
        case .distracted:
            return "Distracted"
        case .chaotic:
            return "Scattered Attention"
        }
    }
}

// MARK: - Extensions

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// MARK: - Preview Support

#Preview("Focus Indicator") {
    AuraFocusIndicator()
        .environmentObject(TimerViewModel())
        .environmentObject(ScreenContext())
        .frame(width: 300, height: 50)
        .background(Color.black)
}

#Preview("Focus Tooltip") {
    FocusTooltip()
        .environmentObject(FocusAwarenessManager.shared)
        .frame(width: 200, height: 120)
        .background(Color.black)
}