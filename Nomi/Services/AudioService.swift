//
//  AudioService.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import Foundation
import AVFoundation

@MainActor
final class AudioService: NSObject, ObservableObject {
    static let shared = AudioService()
    
    private nonisolated(unsafe) let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    
    private override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    // MARK: - Text to Speech
    
    func speak(_ text: String, language: Language, rate: Float = 0.4) {
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language.voiceIdentifier)
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Add slight pause at the end for clarity
        utterance.postUtteranceDelay = 0.1
        
        synthesizer.speak(utterance)
        isSpeaking = true
    }
    
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }
    
    // MARK: - Available Voices
    
    func availableVoice(for language: Language) -> AVSpeechSynthesisVoice? {
        // Try to get enhanced voice first
        let voices = AVSpeechSynthesisVoice.speechVoices()
        
        // Prefer enhanced quality voices
        if let enhanced = voices.first(where: {
            $0.language.starts(with: language.code) && $0.quality == .enhanced
        }) {
            return enhanced
        }
        
        // Fall back to default voice for language
        return AVSpeechSynthesisVoice(language: language.voiceIdentifier)
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension AudioService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
}
