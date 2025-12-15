import SwiftUI
import SwiftData

// MARK: - Learn Session View

struct LearnSessionView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let location: Location
    
    @Query private var allStickerWords: [StickerWord]
    
    @State private var currentIndex: Int = 0
    @State private var generatedWord: GeneratedWord?
    @State private var isLoading = true
    
    private var uncollectedWords: [StickerWord] {
        allStickerWords.filter { $0.location == location.rawValue && !$0.isCollected }
    }
    
    private var currentWord: StickerWord? {
        guard currentIndex < uncollectedWords.count else { return nil }
        return uncollectedWords[currentIndex]
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.backgroundFallback
                .ignoresSafeArea()
            
            DottedGridBackground()
                .ignoresSafeArea()
            
            if uncollectedWords.isEmpty {
                completedView
            } else if let word = currentWord {
                learnCardView(for: word)
            }
        }
        .navigationBarHidden(true)
        .task {
            if let word = currentWord {
                await loadTranslation(for: word)
            }
        }
    }
    
    // MARK: - Learn Card View
    
    private func learnCardView(for word: StickerWord) -> some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                IconButton(systemName: "xmark") {
                    dismiss()
                }
                
                Spacer()
                
                Text("\(currentIndex + 1)/\(uncollectedWords.count)")
                    .font(Theme.Typography.bodyBold(16))
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Spacer()
                
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            
            Spacer()
            
            // Card content
            VStack(spacing: Theme.Spacing.xl) {
                StickerImage(name: word.wordKey, size: 140)
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Theme.Colors.primaryFallback)
                } else if let generated = generatedWord {
                    wordContent(generated)
                }
            }
            
            Spacer()
            
            // Got it button
            if !isLoading && generatedWord != nil {
                PrimaryButton(title: "Got it!") {
                    collectAndNext(word)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.lg)
            }
        }
    }
    
    private func wordContent(_ word: GeneratedWord) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Text(word.translatedWord)
                    .font(Theme.Typography.wordLarge(36))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                AudioButton {
                    appState.audioService.speak(word.translatedWord, language: appState.currentLanguage)
                }
            }
            
            if let romanization = word.romanization {
                Text(romanization)
                    .font(Theme.Typography.romanization(20))
                    .foregroundColor(Theme.Colors.primaryFallback)
            }
            
            Text(word.englishWord)
                .font(Theme.Typography.body(18))
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
    
    // MARK: - Completed View
    
    private var completedView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text("🎉")
                .font(.system(size: 80))
            
            Text("All done!")
                .font(Theme.Typography.headline(28))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("You've learned all the words in this space.")
                .font(Theme.Typography.body(16))
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            PrimaryButton(title: "Back to Space") {
                dismiss()
            }
            .frame(width: 200)
        }
        .padding(Theme.Spacing.xl)
    }
    
    // MARK: - Helpers
    
    private func loadTranslation(for word: StickerWord) async {
        isLoading = true
        
        let englishWord = word.wordKey.replacingOccurrences(of: "_", with: " ").capitalized
        
        do {
            generatedWord = try await appState.openAIService.generateTranslation(
                englishWord: englishWord,
                targetLanguage: appState.currentLanguage,
                context: word.locationEnum
            )
        } catch {
            print("Failed to load translation: \(error)")
        }
        
        isLoading = false
    }
    
    private func collectAndNext(_ word: StickerWord) {
        word.collect()
        appState.hapticService.success()
        
        if currentIndex < uncollectedWords.count - 1 {
            currentIndex += 1
            generatedWord = nil
            
            Task {
                if let nextWord = currentWord {
                    await loadTranslation(for: nextWord)
                }
            }
        } else {
            // Completed all words
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    LearnSessionView(location: .cafe)
        .environment(AppState())
        .modelContainer(for: StickerWord.self, inMemory: true)
}
