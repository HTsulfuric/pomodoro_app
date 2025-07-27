import SwiftUI
import AppKit
import QuartzCore

// MARK: - Advanced Aura Particle View

/// Revolutionary particle system with environmental awareness and physics interaction
/// This is the cutting-edge implementation that responds to focus state and user interaction
struct AuraAdvancedParticleView: NSViewRepresentable {
    @EnvironmentObject var viewModel: TimerViewModel
    @EnvironmentObject var screenContext: ScreenContext
    @StateObject private var focusManager = FocusAwarenessManager.shared
    
    func makeNSView(context: Context) -> NSView {
        let view = AuraAdvancedParticleHostView()
        view.wantsLayer = true
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        guard let hostView = nsView as? AuraAdvancedParticleHostView else { return }
        
        let phase = viewModel.pomodoroState.currentPhase
        let progress = viewModel.pomodoroState.progress
        let isRunning = viewModel.pomodoroState.isRunning
        
        // Advanced features: focus awareness
        let agitation = focusManager.getParticleAgitation()
        let colorIntensity = focusManager.getColorIntensity()
        let birthRateModifier = focusManager.getParticleBirthRateModifier()
        
        hostView.updateAdvancedParticleSystem(
            phase: phase,
            progress: progress,
            isRunning: isRunning,
            agitation: agitation,
            colorIntensity: colorIntensity,
            birthRateModifier: birthRateModifier,
            screenSize: screenContext.screenFrame.size
        )
    }
}

// MARK: - Advanced Particle Host View

/// Advanced NSView that hosts sophisticated particle physics with environmental awareness
class AuraAdvancedParticleHostView: NSView {
    private var emitterLayer: CAEmitterLayer!
    private var orbCell: CAEmitterCell!
    private var expandedCell: CAEmitterCell!
    private var chaosCell: CAEmitterCell!  // For distracted states
    
    private var currentPhase: PomodoroPhase = .work
    private var isInitialized = false
    private var mouseTrackingArea: NSTrackingArea?
    private var lastMousePosition: CGPoint = .zero
    private var mouseInfluence: Double = 0.0
    
    // Physics simulation properties
    private var gravityField: CGPoint = .zero
    private var mouseRepulsionStrength: Double = 0.3
    private var currentAgitation: Double = 0.0
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupAdvancedParticleSystem()
        setupMouseTracking()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAdvancedParticleSystem()
        setupMouseTracking()
    }
    
    override func layout() {
        super.layout()
        if isInitialized {
            updateEmitterPosition()
            updateMouseTrackingArea()
        }
    }
    
    // MARK: - Advanced Particle System Setup
    
    private func setupAdvancedParticleSystem() {
        // Create the emitter layer with advanced capabilities
        emitterLayer = CAEmitterLayer()
        emitterLayer.emitterShape = .point
        emitterLayer.renderMode = .additive
        emitterLayer.fillMode = .both
        
        // Create sophisticated particle cells
        setupOrbCell()
        setupExpandedCell()
        setupChaosCell()
        
        // Start with orb configuration
        emitterLayer.emitterCells = [orbCell]
        
        layer?.addSublayer(emitterLayer)
        isInitialized = true
    }
    
    private func setupOrbCell() {
        orbCell = CAEmitterCell()
        orbCell.contents = createAdvancedParticleImage(size: 48, style: .focused)
        
        // Enhanced orb properties for deep focus
        orbCell.birthRate = 120
        orbCell.lifetime = 6.0
        orbCell.velocity = 12
        orbCell.velocityRange = 4
        orbCell.scale = 0.04
        orbCell.scaleRange = 0.02
        orbCell.scaleSpeed = -0.008
        orbCell.alphaSpeed = -0.15
        
        // Advanced physics properties
        orbCell.emissionRange = CGFloat.pi * 2
        orbCell.spin = 0.3
        orbCell.spinRange = 0.8
        
        // Color will be set dynamically
        orbCell.color = CGColor(red: 129/255, green: 199/255, blue: 244/255, alpha: 0.8)
    }
    
    private func setupExpandedCell() {
        expandedCell = CAEmitterCell()
        expandedCell.contents = createAdvancedParticleImage(size: 40, style: .relaxed)
        
        // Break state properties (free-flowing)
        expandedCell.birthRate = 200
        expandedCell.lifetime = 10.0
        expandedCell.velocity = 30
        expandedCell.velocityRange = 15
        expandedCell.scale = 0.06
        expandedCell.scaleRange = 0.03
        expandedCell.scaleSpeed = -0.01
        expandedCell.alphaSpeed = -0.1
        
        // Upward flowing motion
        expandedCell.emissionRange = CGFloat.pi / 6
        expandedCell.spin = 1.2
        expandedCell.spinRange = 2.0
        
        expandedCell.color = CGColor(red: 167/255, green: 245/255, blue: 229/255, alpha: 0.6)
    }
    
    private func setupChaosCell() {
        chaosCell = CAEmitterCell()
        chaosCell.contents = createAdvancedParticleImage(size: 32, style: .chaotic)
        
        // Chaotic state for distractions
        chaosCell.birthRate = 80
        chaosCell.lifetime = 3.0
        chaosCell.velocity = 60
        chaosCell.velocityRange = 40
        chaosCell.scale = 0.03
        chaosCell.scaleRange = 0.02
        chaosCell.scaleSpeed = -0.02
        chaosCell.alphaSpeed = -0.3
        
        // Erratic, unpredictable motion
        chaosCell.emissionRange = CGFloat.pi * 2
        chaosCell.spin = 3.0
        chaosCell.spinRange = 5.0
        
        chaosCell.color = CGColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.4)
    }
    
    private enum ParticleStyle {
        case focused, relaxed, chaotic
    }
    
    private func createAdvancedParticleImage(size: Int, style: ParticleStyle) -> CGImage? {
        guard let context = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        let center = CGPoint(x: size / 2, y: size / 2)
        let radius = CGFloat(size) / 3.0
        
        // Create different particle styles
        switch style {
        case .focused:
            // Perfect circle with sharp edges for focus
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                    CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
                ] as CFArray,
                locations: [0.0, 1.0]
            )
            
            if let gradient = gradient {
                context.drawRadialGradient(
                    gradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius,
                    options: []
                )
            }
            
        case .relaxed:
            // Soft, diffused particle for breaks
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8),
                    CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2),
                    CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
                ] as CFArray,
                locations: [0.0, 0.5, 1.0]
            )
            
            if let gradient = gradient {
                context.drawRadialGradient(
                    gradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius * 1.5,
                    options: []
                )
            }
            
        case .chaotic:
            // Irregular, jagged particle for distraction
            context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
            
            // Draw irregular star shape
            let points = 8
            for i in 0..<points {
                let angle = CGFloat(i) * CGFloat.pi * 2 / CGFloat(points)
                let distance = (i % 2 == 0) ? radius : radius * 0.5
                let x = center.x + cos(angle) * distance
                let y = center.y + sin(angle) * distance
                
                if i == 0 {
                    context.move(to: CGPoint(x: x, y: y))
                } else {
                    context.addLine(to: CGPoint(x: x, y: y))
                }
            }
            context.closePath()
            context.fillPath()
        }
        
        return context.makeImage()
    }
    
    // MARK: - Mouse Interaction
    
    private func setupMouseTracking() {
        updateMouseTrackingArea()
    }
    
    private func updateMouseTrackingArea() {
        if let trackingArea = mouseTrackingArea {
            removeTrackingArea(trackingArea)
        }
        
        mouseTrackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeInKeyWindow, .mouseMoved, .mouseEnteredAndExited],
            owner: self,
            userInfo: nil
        )
        
        if let trackingArea = mouseTrackingArea {
            addTrackingArea(trackingArea)
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        let locationInView = convert(event.locationInWindow, from: nil)
        lastMousePosition = locationInView
        
        // Calculate mouse influence on particle system
        updateMouseInfluence(at: locationInView)
        
        super.mouseMoved(with: event)
    }
    
    override func mouseEntered(with event: NSEvent) {
        mouseInfluence = 1.0
        super.mouseEntered(with: event)
    }
    
    override func mouseExited(with event: NSEvent) {
        mouseInfluence = 0.0
        super.mouseExited(with: event)
    }
    
    private func updateMouseInfluence(at position: CGPoint) {
        // Create ripple effect around mouse position
        let centerX = bounds.width / 2
        let centerY = bounds.height / 2
        let distance = sqrt(pow(position.x - centerX, 2) + pow(position.y - centerY, 2))
        let maxDistance = sqrt(pow(centerX, 2) + pow(centerY, 2))
        
        // Stronger influence when mouse is closer to center
        mouseInfluence = max(0.0, 1.0 - distance / maxDistance)
        
        // Update gravity field to be repelled by mouse
        let repulsionX = (centerX - position.x) * mouseRepulsionStrength
        let repulsionY = (centerY - position.y) * mouseRepulsionStrength
        gravityField = CGPoint(x: repulsionX, y: repulsionY)
    }
    
    // MARK: - Advanced Dynamic Updates
    
    func updateAdvancedParticleSystem(
        phase: PomodoroPhase,
        progress: Double,
        isRunning: Bool,
        agitation: Double,
        colorIntensity: Double,
        birthRateModifier: Double,
        screenSize: CGSize
    ) {
        guard isInitialized else { return }
        
        currentAgitation = agitation
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(agitation > 0.7 ? 0.8 : 3.0)
        CATransaction.setAnimationTimingFunction(
            CAMediaTimingFunction(name: agitation > 0.5 ? .easeOut : .easeInEaseOut)
        )
        
        // Update colors with intensity and phase
        updateAdvancedParticleColors(for: phase, intensity: colorIntensity)
        
        // Choose appropriate particle system based on focus state
        if agitation > 0.8 {
            // High distraction: use chaos particles
            updateChaoticState(phase: phase, progress: progress, birthRateModifier: birthRateModifier)
        } else if isRunning {
            updateAdvancedRunningState(
                phase: phase,
                progress: progress,
                agitation: agitation,
                birthRateModifier: birthRateModifier,
                screenSize: screenSize
            )
        } else {
            updateAdvancedPausedState(phase: phase, agitation: agitation)
        }
        
        currentPhase = phase
        CATransaction.commit()
    }
    
    private func updateAdvancedParticleColors(for phase: PomodoroPhase, intensity: Double) {
        let colors = getAdvancedColorsForPhase(phase, intensity: intensity)
        
        orbCell.color = colors.primary
        expandedCell.color = colors.accent
        chaosCell.color = colors.chaos
    }
    
    private func getAdvancedColorsForPhase(_ phase: PomodoroPhase, intensity: Double) -> (primary: CGColor, accent: CGColor, chaos: CGColor) {
        let baseColors: (CGColor, CGColor)
        
        switch phase {
        case .work:
            baseColors = (
                CGColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 0.8 * intensity),
                CGColor(red: 129/255, green: 199/255, blue: 244/255, alpha: 0.6 * intensity)
            )
        case .shortBreak:
            baseColors = (
                CGColor(red: 80/255, green: 227/255, blue: 194/255, alpha: 0.8 * intensity),
                CGColor(red: 167/255, green: 245/255, blue: 229/255, alpha: 0.6 * intensity)
            )
        case .longBreak:
            baseColors = (
                CGColor(red: 245/255, green: 166/255, blue: 35/255, alpha: 0.8 * intensity),
                CGColor(red: 248/255, green: 221/255, blue: 170/255, alpha: 0.6 * intensity)
            )
        }
        
        // Chaos color indicates distraction (red-orange)
        let chaosColor = CGColor(
            red: 1.0,
            green: 0.4 * intensity,
            blue: 0.2 * intensity,
            alpha: 0.5 * intensity
        )
        
        return (primary: baseColors.0, accent: baseColors.1, chaos: chaosColor)
    }
    
    private func updateAdvancedRunningState(
        phase: PomodoroPhase,
        progress: Double,
        agitation: Double,
        birthRateModifier: Double,
        screenSize: CGSize
    ) {
        if phase == .work {
            // Enhanced focus mode with mouse interaction
            emitterLayer.emitterShape = .point
            emitterLayer.emitterCells = [orbCell]
            
            // Position at center, influenced by mouse
            let centerX = bounds.width / 2 + gravityField.x * mouseInfluence
            let centerY = bounds.height / 2 + gravityField.y * mouseInfluence
            emitterLayer.emitterPosition = CGPoint(x: centerX, y: centerY)
            emitterLayer.emitterSize = CGSize(width: 20 + agitation * 30, height: 20 + agitation * 30)
            
            // Update orb physics with agitation and mouse influence
            updateAdvancedOrbPhysics(progress: progress, agitation: agitation, birthRateModifier: birthRateModifier)
            
        } else {
            // Enhanced break mode
            emitterLayer.emitterShape = .line
            emitterLayer.emitterCells = [expandedCell]
            
            // Position influenced by mouse repulsion
            let baseY = bounds.height * 0.2
            let mouseInfluencedY = baseY + gravityField.y * mouseInfluence * 0.5
            emitterLayer.emitterPosition = CGPoint(x: bounds.width / 2, y: mouseInfluencedY)
            emitterLayer.emitterSize = CGSize(width: bounds.width * (0.8 + agitation * 0.2), height: 20)
            
            // Update expansion physics
            updateAdvancedExpansionPhysics(agitation: agitation, birthRateModifier: birthRateModifier)
        }
    }
    
    private func updateChaoticState(phase: PomodoroPhase, progress: Double, birthRateModifier: Double) {
        // High distraction: chaotic particle behavior
        emitterLayer.emitterShape = .rectangle
        emitterLayer.emitterCells = [chaosCell]
        
        // Randomized emission across the entire view
        emitterLayer.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        emitterLayer.emitterSize = CGSize(width: bounds.width, height: bounds.height)
        
        // Highly erratic behavior
        chaosCell.birthRate = Float(60 * birthRateModifier)
        chaosCell.velocity = 80
        chaosCell.velocityRange = 60
        chaosCell.emissionRange = CGFloat.pi * 2
    }
    
    private func updateAdvancedOrbPhysics(progress: Double, agitation: Double, birthRateModifier: Double) {
        // Enhanced orb concentration with environmental factors
        let concentrationFactor = 0.5 + (progress * 0.5) - (agitation * 0.3)
        let mouseDisturbance = mouseInfluence * 0.4
        
        orbCell.birthRate = Float(120 * birthRateModifier * (1.0 + mouseDisturbance))
        orbCell.velocity = CGFloat(15 * concentrationFactor + agitation * 10)
        orbCell.velocityRange = CGFloat(5 * concentrationFactor + agitation * 8)
        
        // Mouse influence creates swirling motion
        if mouseInfluence > 0.3 {
            orbCell.spin = CGFloat(2.0 + mouseInfluence * 3.0)
            orbCell.spinRange = CGFloat(mouseInfluence * 4.0)
        } else {
            orbCell.spin = 0.3
            orbCell.spinRange = 0.8
        }
        
        // Emission becomes more scattered with agitation
        orbCell.emissionRange = CGFloat.pi * 2 * (1.0 + agitation)
    }
    
    private func updateAdvancedExpansionPhysics(agitation: Double, birthRateModifier: Double) {
        // Enhanced break expansion with environmental response
        expandedCell.birthRate = Float(200 * birthRateModifier * (1.0 + agitation * 0.5))
        expandedCell.velocity = CGFloat(30 + agitation * 20)
        expandedCell.velocityRange = CGFloat(15 + agitation * 15)
        
        // More chaotic motion when distracted
        expandedCell.emissionRange = CGFloat.pi / 6 * (1.0 + agitation * 2.0)
        expandedCell.spin = CGFloat(1.2 + agitation * 2.0)
        expandedCell.spinRange = CGFloat(2.0 + agitation * 3.0)
    }
    
    private func updateAdvancedPausedState(phase: PomodoroPhase, agitation: Double) {
        // Reduce particle activity when paused
        orbCell.birthRate = Float(30 * (1.0 - agitation * 0.5))
        expandedCell.birthRate = Float(50 * (1.0 - agitation * 0.3))
        chaosCell.birthRate = Float(20 * agitation)
    }
    
    private func updateEmitterPosition() {
        guard isInitialized else { return }
        
        if currentPhase == .work {
            let centerX = bounds.width / 2 + gravityField.x * mouseInfluence
            let centerY = bounds.height / 2 + gravityField.y * mouseInfluence
            emitterLayer.emitterPosition = CGPoint(x: centerX, y: centerY)
        } else {
            let baseY = bounds.height * 0.2
            let mouseInfluencedY = baseY + gravityField.y * mouseInfluence * 0.5
            emitterLayer.emitterPosition = CGPoint(x: bounds.width / 2, y: mouseInfluencedY)
            emitterLayer.emitterSize = CGSize(width: bounds.width * 0.8, height: 20)
        }
    }
}

// MARK: - Preview Support

#Preview("Advanced Aura Particles") {
    AuraAdvancedParticleView()
        .environmentObject(TimerViewModel())
        .environmentObject(ScreenContext())
        .frame(width: 800, height: 600)
        .background(Color.black)
}