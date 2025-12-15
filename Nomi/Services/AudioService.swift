import Foundation
import AVFoundation

// MARK: - Audio Service

@MainActor
class AudioService: ObservableObject {
    
    static let shared = AudioService()
    
    @Published var isPlaying = false
    @Published var currentlyPlayingID: String?
    
    private let synthesizer = AVSpeechSynthesizer()
    private var delegate: AudioServiceDelegate?
    
    private init() {
        delegate = AudioServiceDelegate { [weak self] in
            self?.isPlaying = false
            self?.currentlyPlayingID = nil
        }
        synthesizer.delegate = delegate
        
        // Configure audio session
        configureAudioSession()
    }
    
    // MARK: - Public Methods
    
    /// Speaks the given text in the specified language
    func speak(_ text: String, language: Language, id: String? = nil) {
        guard Config.Features.enableTTS else { return }
        
        // Stop any current speech
        stop()
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language.languageCode)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9 // Slightly slower for learning
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        isPlaying = true
        currentlyPlayingID = id
        
        synthesizer.speak(utterance)
    }
    
    /// Stops any current speech
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isPlaying = false
        currentlyPlayingID = nil
    }
    
    /// Check if a specific item is currently playing
    func isPlaying(id: String) -> Bool {
        return isPlaying && currentlyPlayingID == id
    }
    
    // MARK: - Private Methods
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
}

// MARK: - Audio Service Delegate

private class AudioServiceDelegate: NSObject, AVSpeechSynthesizerDelegate {
    
    let onFinish: () -> Void
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.onFinish()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.onFinish()
        }
    }
}
