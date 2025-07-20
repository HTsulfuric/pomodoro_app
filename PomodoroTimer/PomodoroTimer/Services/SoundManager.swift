import Foundation
import AVFoundation
import AudioToolbox
import AppKit

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        // No audio session setup needed on macOS
    }
    
    func playPhaseChangeSound(for phase: PomodoroPhase) {
        print("🔊 =================================")
        print("🔊 SOUND MANAGER: playPhaseChangeSound called")
        print("🔊 Phase: \(phase)")
        
        // Use macOS system sounds
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
        
        // Play system sound once at full volume
        if let sound = NSSound(named: soundName) {
            print("🔊 NSSound found: \(soundName)")
            sound.volume = 1.0 // Maximum volume
            let success = sound.play()
            print("🔊 NSSound.play() returned: \(success)")
            if success {
                print("✅ SUCCESS: NSSound played")
            } else {
                print("❌ FAILED: NSSound.play() returned false")
            }
        } else {
            print("❌ FAILED: NSSound(named: \(soundName)) returned nil")
            // Fallback to system beep if sound not found
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
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.volume = 0.8 // Set to 80% volume to be noticeable but not jarring
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    func playTimerTickSound() {
        // Subtle tick sound for last 10 seconds (optional)
        if let tickSound = NSSound(named: "Tink") {
            tickSound.volume = 0.3 // Very quiet
            tickSound.play()
        } else {
            // Fallback to very quiet system sound
            AudioServicesPlaySystemSound(1000)
        }
    }
}