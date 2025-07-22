import Foundation
import AVFoundation
import AudioToolbox
import AppKit

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var currentSound: NSSound?
    
    init() {
        print("🎵 SoundManager initialized with simple NSSound approach")
    }
    
    func playPhaseChangeSound(for phase: PomodoroPhase) {
        print("🔊 =================================")
        print("🔊 NSSound MANAGER: playPhaseChangeSound called")
        print("🔊 Phase: \(phase)")
        
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
        
        print("🔊 Selected sound name: \(soundName)")
        
        // NSSound automatically handles system sounds by name (sandbox-friendly)
        if let sound = NSSound(named: soundName) {
            print("🔊 NSSound found: \(soundName)")
            
            // Store reference to prevent deallocation during playback
            currentSound = sound
            
            // Set maximum volume for notification priority
            sound.volume = 1.0
            
            // Play the sound - simple and reliable
            let success = sound.play()
            
            print("🔊 NSSound.play() returned: \(success)")
            if success {
                print("✅ SUCCESS: NSSound played - should be audible")
            } else {
                print("❌ FAILED: NSSound.play() returned false")
            }
        } else {
            print("❌ FAILED: NSSound(named: \(soundName)) returned nil")
            // Fallback to system beep
            NSSound.beep()
            print("🔊 Fallback: NSSound.beep() called")
        }
        
        print("🔊 =================================")
    }
    
    
    func playCustomSound(named soundName: String) {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Could not find sound file: \(soundName)")
            return
        }
        
        // Use NSSound for custom sounds as well - simpler and more reliable
        if let sound = NSSound(contentsOf: soundURL, byReference: false) {
            currentSound = sound
            sound.volume = 0.8 // Set to 80% volume for custom sounds
            let success = sound.play()
            print(success ? "✅ Custom sound played: \(soundName)" : "❌ Failed to play custom sound: \(soundName)")
        } else {
            print("❌ Failed to create NSSound from: \(soundURL)")
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