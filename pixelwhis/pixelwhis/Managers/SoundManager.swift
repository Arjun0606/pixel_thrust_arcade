import AVFoundation
import SwiftUI
import Combine

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var sfxPlayers: [String: AVAudioPlayer] = [:]
    
    @Published var isMuted: Bool = false
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Background Music
    func playAmbientMusic() {
        guard !isMuted else { return }
        
        // In a real app, we'd load a file like "ambient_loop.mp3"
        // For now, this is a placeholder structure
        /*
        guard let url = Bundle.main.url(forResource: "ambient_loop", withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Infinite loop
            audioPlayer?.volume = 0.3
            audioPlayer?.play()
        } catch {
            print("Could not play ambient music: \(error)")
        }
        */
    }
    
    func stopMusic() {
        audioPlayer?.stop()
    }
    
    // MARK: - Sound Effects
    // MARK: - Game SFX
    func playThrust() {
        guard !isMuted else { return }
        playHaptic(.light)
    }
    
    func playExplosion() {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(1006)
        playNotificationHaptic(.error)
    }
    
    func playScore() {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(1057)
        playHaptic(.medium)
    }
    
    func playButton() {
        AudioServicesPlaySystemSound(1104)
        playHaptic(.medium)
    }

    // Legacy Support
    func playSFX(_ name: String) {
        guard !isMuted else { return }
        switch name {
        case "coin": AudioServicesPlaySystemSound(1103)
        case "evolve": AudioServicesPlaySystemSound(1025)
        case "click": playButton()
        default: break
        }
    }
    
    // MARK: - Haptics
    #if canImport(UIKit)
    func playHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func playNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    #else
    func playHaptic(_ style: Int) {}
    func playNotificationHaptic(_ type: Int) {}
    #endif
}
