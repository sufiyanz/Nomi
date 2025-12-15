import SwiftUI
import SwiftData

// MARK: - Review Session View

struct RevisionSessionView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    let location: Location
    
    @Query private var allStickerWords: [StickerWord]
    
    @State private var currentIndex: Int = 0
    @State private var showAnswer = false
    @State private var generatedWords: [String: GeneratedWord] = [:]
    @State private var isLoadingTranslation = false
    
    private var wordsToReview: [StickerWord] {
        allStickerWords
            .filter { $0.location == location.rawValue && $0.isCollected }
            .sorted { ($0.nextReviewDate ?? .distantPast) < ($1.nextReviewDate ?? .distantPast) }
    }
    
    private var currentWord: StickerWord? {
        guard currentIndex < wordsToReview.count else { return nil }
        return wordsToReview[currentIndex]
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.backgroundFallback
                .ignoresSafeArea()
            
            DottedGridBackground()
                .ignoresSafeArea()
            
            if wordsToReview.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Card content
                    TabView(selection: $currentIndex) {
                        ForEach(Array(wordsToReview.enumerated()), id: \.element.id) { index, word in
                            reviewCard(for: word)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .onChange(of: currentIndex) { _, _ in
                        showAnswer = false
                    }
                    
                    // Rating buttons
                    if showAnswer {
                        ratingButtons
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            IconButton(systemName: "xmark", action: {
                dismiss()
            })
            
            Spacer()
            
            Text("\(currentIndex + 1)/\(wordsToReview.count)")
                .font(Theme.Typography.bodyBold(16))
                .foregroundColor(Theme.Colors.textSecondary)
            
            Spacer()
            
            // Placeholder for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
    }
    
    // MARK: - Review Card
    
    private func reviewCard(for word: StickerWord) -> some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            // Sticker
            StickerImage(name: word.wordKey, size: 140)
            
            // Word content
            if let generated = generatedWords[word.id] {
                VStack(spacing: Theme.Spacing.sm) {
                    // Target language word
                    HStack(spacing: Theme.Spacing.sm) {
                        Text(generated.translatedWord)
                            .font(Theme.Typography.wordLarge(36))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        AudioButton {
                            appState.audioService.speak(
                                generated.translatedWord,
                                language: appState.currentLanguage
                            )
                        }
                    }
                    
                    // Romanization
                    if let romanization = generated.romanization {
                        Text(romanization)
                            .font(Theme.Typography.romanization(20))
                            .foregroundColor(Theme.Colors.primaryFallback)
                    }
                    
                    // Answer section (shown/hidden)
                    if showAnswer {
                        answerSection(for: generated)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        showAnswerButton
                    }
                }
            } else if isLoadingTranslation {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(Theme.Colors.primaryFallback)
            } else {
                Text(word.wordKey.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(Theme.Typography.wordLarge(28))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                showAnswerButton
            }
            
            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .task {
            await loadTranslation(for: word)
        }
    }
    
    // MARK: - Answer Section
    
    private func answerSection(for word: GeneratedWord) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            Divider()
                .background(Theme.Colors.textMuted.opacity(0.3))
                .padding(.vertical, Theme.Spacing.sm)
            
            // English translation
            Text(word.englishWord)
                .font(Theme.Typography.bodyBold(20))
                .foregroundColor(Theme.Colors.textPrimary)
            
            // Example sentence
            VStack(spacing: Theme.Spacing.xs) {
                HStack {
                    Text(word.exampleSentence)
                        .font(Theme.Typography.body(14))
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    AudioButton(action: {
                        appState.audioService.speak(
                            word.exampleSentence,
                            language: appState.currentLanguage
                        )
                    }, size: 18)
                }
                
                Text(word.exampleTranslation)
                    .font(Theme.Typography.body(14))
                    .foregroundColor(Theme.Colors.primaryFallback)
            }
        }
        .animation(Theme.Animation.spring, value: showAnswer)
    }
    
    // MARK: - Show Answer Button
    
    private var showAnswerButton: some View {
        Button(action: {
            withAnimation(Theme.Animation.spring) {
                showAnswer = true
            }
            appState.hapticService.lightImpact()
        }) {
            Text("Show Answer")
                .font(Theme.Typography.bodyBold(16))
                .foregroundColor(Theme.Colors.primaryFallback)
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.vertical, Theme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                        .stroke(Theme.Colors.primaryFallback, lineWidth: 2)
                )
        }
        .padding(.top, Theme.Spacing.lg)
    }
    
    // MARK: - Rating Buttons
    
    private var ratingButtons: some View {
        HStack(spacing: Theme.Spacing.md) {
            ForEach(ReviewDifficulty.allCases, id: \.rawValue) { difficulty in
                DifficultyButton(difficulty: difficulty) {
                    rateWord(difficulty)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.lg)
        .background(Color.black.opacity(0.3))
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.textMuted)
            
            Text("No words to review yet")
                .font(Theme.Typography.title(20))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("Explore the space to collect some!")
                .font(Theme.Typography.body(14))
                .foregroundColor(Theme.Colors.textSecondary)
            
            SecondaryButton(title: "Go Back") {
                dismiss()
            }
            .frame(width: 160)
        }
    }
    
    // MARK: - Actions
    
    private func loadTranslation(for word: StickerWord) async {
        guard generatedWords[word.id] == nil else { return }
        
        isLoadingTranslation = true
        
        let englishWord = word.wordKey.replacingOccurrences(of: "_", with: " ").capitalized
        
        do {
            let generated = try await appState.openAIService.generateTranslation(
                englishWord: englishWord,
                targetLanguage: appState.currentLanguage,
                context: word.locationEnum
            )
            generatedWords[word.id] = generated
        } catch {
            print("Failed to load translation: \(error)")
        }
        
        isLoadingTranslation = false
    }
    
    private func rateWord(_ difficulty: ReviewDifficulty) {
        guard let word = currentWord else { return }
        
        word.recordReview(difficulty: difficulty)
        appState.hapticService.mediumImpact()
        
        // Move to next card
        withAnimation(Theme.Animation.standard) {
            if currentIndex < wordsToReview.count - 1 {
                currentIndex += 1
                showAnswer = false
            } else {
                // Session complete
                dismiss()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    RevisionSessionView(location: .cafe)
        .environment(AppState())
        .modelContainer(for: StickerWord.self, inMemory: true)
}
