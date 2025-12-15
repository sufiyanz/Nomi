import SwiftUI
import SwiftData

// MARK: - Word Card View

struct WordCardView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    let stickerWord: StickerWord
    let language: Language
    let onCollect: () -> Void
    
    @State private var generatedWord: GeneratedWord?
    @State private var isLoading = true
    @State private var error: Error?
    @State private var isPlayingWord = false
    @State private var isPlayingSentence = false
    
    private var englishWord: String {
        stickerWord.wordKey.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    var body: some View {
        ZStack {
            // Background
            Theme.Colors.cardBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    CloseButton(action: { dismiss() })
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Sticker
                        StickerImage(name: stickerWord.wordKey, size: 120)
                            .padding(.top, Theme.Spacing.md)
                        
                        if isLoading {
                            loadingView
                        } else if let word = generatedWord {
                            wordContentView(word)
                        } else if let error = error {
                            errorView(error)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                }
                
                // Got it button
                if !isLoading && generatedWord != nil && !stickerWord.isCollected {
                    PrimaryButton(title: "Got it") {
                        onCollect()
                        dismiss()
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.bottom, Theme.Spacing.lg)
                } else if stickerWord.isCollected {
                    collectedBadge
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.bottom, Theme.Spacing.lg)
                }
            }
        }
        .task {
            await loadTranslation()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: Theme.Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Theme.Colors.primaryFallback)
            
            Text("Loading translation...")
                .font(Theme.Typography.body(14))
                .foregroundColor(Theme.Colors.textMuted)
        }
        .frame(height: 200)
    }
    
    // MARK: - Word Content View
    
    private func wordContentView(_ word: GeneratedWord) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Translated word with audio
            VStack(spacing: Theme.Spacing.xs) {
                HStack(spacing: Theme.Spacing.sm) {
                    Text(word.translatedWord)
                        .font(Theme.Typography.wordLarge(32))
                        .foregroundColor(Theme.Colors.cardText)
                    
                    AudioButton(action: {
                        playWord(word)
                    }, isPlaying: isPlayingWord)
                }
                
                // Romanization
                if let romanization = word.romanization {
                    Text(romanization)
                        .font(Theme.Typography.romanization(18))
                        .foregroundColor(Theme.Colors.primaryFallback)
                }
            }
            
            Divider()
                .background(Theme.Colors.textMuted.opacity(0.3))
            
            // English translation
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("English")
                    .font(Theme.Typography.caption(12))
                    .foregroundColor(Theme.Colors.textMuted)
                
                Text(englishWord)
                    .font(Theme.Typography.bodyBold(18))
                    .foregroundColor(Theme.Colors.cardText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Example sentence
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Word in use")
                    .font(Theme.Typography.caption(12))
                    .foregroundColor(Theme.Colors.textMuted)
                
                HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text(word.exampleSentence)
                            .font(Theme.Typography.body(16))
                            .foregroundColor(Theme.Colors.cardText)
                        
                        if let romanization = word.exampleRomanization {
                            Text(romanization)
                                .font(Theme.Typography.caption(14))
                                .foregroundColor(Theme.Colors.textMuted)
                        }
                    }
                    
                    Spacer()
                    
                    AudioButton(action: {
                        playSentence(word)
                    }, isPlaying: isPlayingSentence)
                }
                
                Text(word.exampleTranslation)
                    .font(Theme.Typography.body(14))
                    .foregroundColor(Theme.Colors.primaryFallback)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Error View
    
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(Theme.Colors.warning)
            
            Text("Failed to load translation")
                .font(Theme.Typography.bodyBold(16))
                .foregroundColor(Theme.Colors.cardText)
            
            Text(error.localizedDescription)
                .font(Theme.Typography.caption(12))
                .foregroundColor(Theme.Colors.textMuted)
                .multilineTextAlignment(.center)
            
            SecondaryButton(title: "Retry") {
                Task {
                    await loadTranslation()
                }
            }
            .frame(width: 120)
        }
        .padding(Theme.Spacing.lg)
    }
    
    // MARK: - Collected Badge
    
    private var collectedBadge: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Theme.Colors.success)
            
            Text("Already collected!")
                .font(Theme.Typography.bodyBold(16))
                .foregroundColor(Theme.Colors.cardText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.md)
        .background(Theme.Colors.success.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.large))
    }
    
    // MARK: - Actions
    
    private func loadTranslation() async {
        isLoading = true
        error = nil
        
        do {
            let word = try await appState.openAIService.generateTranslation(
                englishWord: englishWord,
                targetLanguage: language,
                context: stickerWord.locationEnum
            )
            generatedWord = word
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    private func playWord(_ word: GeneratedWord) {
        isPlayingWord = true
        appState.audioService.speak(word.translatedWord, language: language, id: "word")
        
        // Reset after a delay (TTS doesn't have completion callback)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isPlayingWord = false
        }
    }
    
    private func playSentence(_ word: GeneratedWord) {
        isPlayingSentence = true
        appState.audioService.speak(word.exampleSentence, language: language, id: "sentence")
        
        // Reset after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            isPlayingSentence = false
        }
    }
}

// MARK: - Preview

#Preview {
    let word = StickerWord(
        wordKey: "coffee_cup",
        location: .cafe,
        positionX: 0.5,
        positionY: 0.5
    )
    
    return WordCardView(
        stickerWord: word,
        language: .japanese,
        onCollect: {}
    )
    .environment(AppState())
}
