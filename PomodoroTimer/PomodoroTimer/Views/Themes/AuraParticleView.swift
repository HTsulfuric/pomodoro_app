import SwiftUI
import AppKit
import QuartzCore

// MARK: - Aura Particle View

/// NSViewRepresentable wrapper for CAEmitterLayer particle system
/// Creates the living, breathing aura that responds to timer states
struct AuraParticleView: NSViewRepresentable {
    @EnvironmentObject var viewModel: TimerViewModel
    @EnvironmentObject var screenContext: ScreenContext
    
    func makeNSView(context: Context) -> NSView {
        let view = AuraParticleHostView()
        view.wantsLayer = true
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        guard let hostView = nsView as? AuraParticleHostView else { return }
        
        let phase = viewModel.pomodoroState.currentPhase
        let progress = viewModel.pomodoroState.progress
        let isRunning = viewModel.pomodoroState.isRunning
        
        hostView.updateParticleSystem(
            phase: phase,
            progress: progress,
            isRunning: isRunning,
            screenSize: screenContext.screenFrame.size
        )
    }
}

// MARK: - Particle Host View

/// NSView that hosts the CAEmitterLayer and manages particle physics
class AuraParticleHostView: NSView {
    private var emitterLayer: CAEmitterLayer!
    private var orbCell: CAEmitterCell!
    private var expandedCell: CAEmitterCell!
    private var attractorField: NSObject?
    
    private var currentPhase: PomodoroPhase = .work
    private var isInitialized = false
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupParticleSystem()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupParticleSystem()
    }
    
    override func layout() {
        super.layout()
        if isInitialized {
            updateEmitterPosition()
        }
    }
    
    // MARK: - Particle System Setup
    
    private func setupParticleSystem() {
        // Create the emitter layer
        emitterLayer = CAEmitterLayer()
        emitterLayer.emitterShape = .point
        emitterLayer.renderMode = .additive
        emitterLayer.fillMode = .both
        
        // Create particle cells for different states
        setupOrbCell()
        setupExpandedCell()
        
        // Start with orb configuration
        emitterLayer.emitterCells = [orbCell]
        
        layer?.addSublayer(emitterLayer)
        isInitialized = true
    }
    
    private func setupOrbCell() {
        orbCell = CAEmitterCell()
        
        // Create particle image
        orbCell.contents = createParticleImage(size: 32)
        
        // Orb state properties (focused, concentrated)
        orbCell.birthRate = 150
        orbCell.lifetime = 5.0
        orbCell.velocity = 15
        orbCell.velocityRange = 5
        orbCell.scale = 0.05
        orbCell.scaleRange = 0.02
        orbCell.scaleSpeed = -0.01
        orbCell.alphaSpeed = -0.2
        
        // Color will be set dynamically
        orbCell.color = CGColor(red: 129/255, green: 199/255, blue: 244/255, alpha: 0.8)
        
        // Emission properties for orb formation
        orbCell.emissionRange = CGFloat.pi * 2  // 360 degrees
        orbCell.spin = 0.5
        orbCell.spinRange = 1.0
    }
    
    private func setupExpandedCell() {
        expandedCell = CAEmitterCell()
        
        // Use same particle image
        expandedCell.contents = createParticleImage(size: 32)
        
        // Expanded state properties (free, flowing)
        expandedCell.birthRate = 300
        expandedCell.lifetime = 8.0
        expandedCell.velocity = 40
        expandedCell.velocityRange = 20
        expandedCell.scale = 0.08
        expandedCell.scaleRange = 0.04
        expandedCell.scaleSpeed = -0.01
        expandedCell.alphaSpeed = -0.15
        
        // Color will be set dynamically
        expandedCell.color = CGColor(red: 167/255, green: 245/255, blue: 229/255, alpha: 0.6)
        
        // Emission properties for expansion
        expandedCell.emissionRange = CGFloat.pi / 4  // 45 degree cone upward
        expandedCell.spin = 1.0
        expandedCell.spinRange = 2.0
    }
    
    private func createParticleImage(size: Int) -> CGImage? {
        _ = CGRect(x: 0, y: 0, width: size, height: size)
        
        guard let context = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        // Create a soft, blurred circle
        context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        // Draw gradient circle
        let center = CGPoint(x: size / 2, y: size / 2)
        let radius = CGFloat(size) / 2.5
        
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
        
        return context.makeImage()
    }
    
    // MARK: - Dynamic Updates
    
    func updateParticleSystem(phase: PomodoroPhase, progress: Double, isRunning: Bool, screenSize: CGSize) {
        guard isInitialized else { return }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.5)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        
        // Update colors based on phase
        updateParticleColors(for: phase)
        
        // Update emitter configuration based on state
        if isRunning {
            updateRunningState(phase: phase, progress: progress, screenSize: screenSize)
        } else {
            updatePausedState(phase: phase, screenSize: screenSize)
        }
        
        currentPhase = phase
        CATransaction.commit()
    }
    
    private func updateParticleColors(for phase: PomodoroPhase) {
        let colors = getColorsForPhase(phase)
        
        orbCell.color = colors.primary
        expandedCell.color = colors.accent
    }
    
    private func getColorsForPhase(_ phase: PomodoroPhase) -> (primary: CGColor, accent: CGColor) {
        switch phase {
        case .work:
            return (
                primary: CGColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 0.8),
                accent: CGColor(red: 129/255, green: 199/255, blue: 244/255, alpha: 0.6)
            )
        case .shortBreak:
            return (
                primary: CGColor(red: 80/255, green: 227/255, blue: 194/255, alpha: 0.8),
                accent: CGColor(red: 167/255, green: 245/255, blue: 229/255, alpha: 0.6)
            )
        case .longBreak:
            return (
                primary: CGColor(red: 245/255, green: 166/255, blue: 35/255, alpha: 0.8),
                accent: CGColor(red: 248/255, green: 221/255, blue: 170/255, alpha: 0.6)
            )
        }
    }
    
    private func updateRunningState(phase: PomodoroPhase, progress: Double, screenSize: CGSize) {
        if phase == .work {
            // Focus mode: Particles form concentrated orb
            emitterLayer.emitterShape = .point
            emitterLayer.emitterCells = [orbCell]
            
            // Position at center
            emitterLayer.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            emitterLayer.emitterSize = CGSize(width: 20, height: 20)
            
            // Simulate gravity pulling inward (orb formation)
            updateOrbPhysics(progress: progress)
            
        } else {
            // Break mode: Particles expand and flow freely
            emitterLayer.emitterShape = .line
            emitterLayer.emitterCells = [expandedCell]
            
            // Position at bottom center for upward flow
            emitterLayer.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height * 0.2)
            emitterLayer.emitterSize = CGSize(width: bounds.width * 0.8, height: 20)
            
            // Add upward gravity for expansion
            updateExpansionPhysics()
        }
    }
    
    private func updatePausedState(phase: PomodoroPhase, screenSize: CGSize) {
        // Reduce particle birth rate when paused
        orbCell.birthRate = 50
        expandedCell.birthRate = 100
    }
    
    private func updateOrbPhysics(progress: Double) {
        // Adjust particle concentration based on timer progress
        let concentrationFactor = 0.5 + (progress * 0.5)  // 0.5 to 1.0
        
        orbCell.velocity = CGFloat(15 * concentrationFactor)
        orbCell.velocityRange = CGFloat(5 * concentrationFactor)
        
        // Simulate stronger "pull" as time progresses
        orbCell.emissionRange = CGFloat.pi * 2 * (2.0 - concentrationFactor)
    }
    
    private func updateExpansionPhysics() {
        // Configure for upward expansion
        expandedCell.emissionRange = CGFloat.pi / 6  // 30 degree cone
        expandedCell.velocity = 40
        expandedCell.velocityRange = 20
    }
    
    private func updateEmitterPosition() {
        guard isInitialized else { return }
        
        if currentPhase == .work {
            emitterLayer.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        } else {
            emitterLayer.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height * 0.2)
            emitterLayer.emitterSize = CGSize(width: bounds.width * 0.8, height: 20)
        }
    }
}

// MARK: - Preview Support

#Preview("Aura Particles") {
    AuraParticleView()
        .environmentObject(TimerViewModel())
        .environmentObject(ScreenContext())
        .frame(width: 800, height: 600)
        .background(Color.black)
}