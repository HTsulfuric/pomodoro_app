import Foundation
import AppKit

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var currentSound: NSSound?
    
    init() {
    }
    
    func playPhaseChangeSound(for phase: PomodoroPhase) {
        // Use simple NSSound approach - reliable and audible
        let soundName: String
        
        switch phase {
        case .work:
            soundName = "Glass" // Work session complete - clear, bright sound
        case .shortBreak:
            soundName = "Ping" // Break complete - crisp, clear notification
        case .longBreak:
            soundName = "Sosumi" // Long break complete - distinctive sound
        }
        
        // NSSound automatically handles system sounds by name (sandbox-friendly)
        if let sound = NSSound(named: soundName) {
            // Store reference to prevent deallocation during playback
            currentSound = sound
            
            // Set maximum volume for notification priority
            sound.volume = 1.0
            
            // Play the sound - simple and reliable
            let success = sound.play()
        } else {
            // Fallback to system beep
            NSSound.beep()
        }
    }
    
    func playCustomSound(named soundName: String) {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            Logger.error("Could not find sound file: \(soundName)", category: .sound)
            return
        }
        
        // Use NSSound for custom sounds as well - simpler and more reliable
        if let sound = NSSound(contentsOf: soundURL, byReference: false) {
            currentSound = sound
            sound.volume = 0.8 // Set to 80% volume for custom sounds
            let success = sound.play()
            if success {
                Logger.info("Custom sound played: \(soundName)", category: .sound)
            } else {
                Logger.warning("Failed to play custom sound: \(soundName)", category: .sound)
            }
        } else {
            Logger.error("Failed to create NSSound from: \(soundURL)", category: .sound)
        }
    }
    
    func playTimerTickSound() {
        // Subtle tick sound for last 10 seconds
        if let tickSound = NSSound(named: "Tink") {
            // Don't store reference for tick sounds (they're very short)
            tickSound.volume = 0.3 // Very quiet
            tickSound.play()
        } else {
            // Fallback to system beep
            NSSound.beep()
        }
    }
}
