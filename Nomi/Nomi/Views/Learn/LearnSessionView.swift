//
//  LearnSessionView.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import SwiftUI
import SwiftData
import os.log

private let logger = Logger(subsystem: "com.nomi.app", category: "LearnSession")

struct LearnSessionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let location: Location
    
    @State private var generatedWords: [GeneratedWord] = []
    @State private var currentIndex = 0
    @State private var isLoading = true
    @State private var error: String?
    @State private var collectedCount = 0
    @State private var showSummary = false
    @State private var isGeneratingImage = false
    
    @StateObject private var audioService = AudioService.shared
    
    var body: some View {
        let _ = print("🔴 [LearnSession] body evaluated - isLoading:\(isLoading), wordsCount:\(generatedWords.count), currentIndex:\(currentIndex), error:\(error ?? "none")")
        ZStack {
            LinearGradient.nomiBackground
                .ignoresSafeArea()
            
            if isLoading {
                loadingView
            } else if let error = error {
                errorView(error)
            } else if showSummary {
                summaryView
            } else if generatedWords.isEmpty {
                // No words available
                noWordsView
            } else if currentIndex < generatedWords.count {
                wordCardView
            } else {
                // Fallback - should never happen
                VStack {
                    Text("Unexpected state")
                    Text("isLoading: \(isLoading)")
                    Text("error: \(error ?? "nil")")
                    Text("showSummary: \(showSummary)")
                    Text("words: \(generatedWords.count)")
                    Text("index: \(currentIndex)")
                }
            }
        }
    }
    
    // MARK: - No Words View
    
    private var noWordsView: some View {
        VStack(spacing: NomiSpacing.large) {
            Text("🎉")
                .font(.system(size: 60))
            
            Text("All caught up!")
                .font(.nomiHeadline())
                .foregroundColor(.nomiTextDark)
            
            Text("You've learned all the words for this location. Come back later for more!")
                .font(.nomiBody())
                .foregroundColor(.nomiTextLight)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            #if DEBUG
            // Debug info
            VStack(alignment: .leading, spacing: 4) {
                Text("Debug Info:")
                    .font(.caption.bold())
                Text("Location: \(location.rawValue)")
                    .font(.caption)
                Text("Language: \(appState.selectedLanguage?.rawValue ?? "nil")")
                    .font(.caption)
                Text("Journal nil: \(appState.currentJournal == nil)")
                    .font(.caption)
                let predefined = PredefinedVocabulary.words(for: appState.selectedLanguage ?? .japanese, location: location)
                Text("Predefined count: \(predefined.count)")
                    .font(.caption)
            }
            .foregroundColor(.gray)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            #endif
            
            KawaiiButton(title: "Go Back", style: .primary) {
                dismiss()
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: NomiSpacing.large) {
            Text("✨")
                .font(.system(size: 60))
                .floating()
            
            Text("Preparing words...")
                .font(.nomiHeadline())
                .foregroundColor(.nomiTextDark)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .nomiPink))
        }
        .onAppear {
            print("🔴 [LearnSession] loadingView onAppear triggered")
            loadWords()
        }
    }
    
    // MARK: - Error View
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: NomiSpacing.large) {
            Text("😢")
                .font(.system(size: 60))
            
            Text("Oops!")
                .font(.nomiHeadline())
                .foregroundColor(.nomiTextDark)
            
            Text(message)
                .font(.nomiBody())
                .foregroundColor(.nomiTextLight)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: NomiSpacing.medium) {
                KawaiiButton(title: "Try Again", style: .secondary) {
                    error = nil
                    isLoading = true
                    loadWords()
                }
                
                KawaiiButton(title: "Go Back", style: .outline) {
                    dismiss()
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Word Card View
    
    private var wordCardView: some View {
        VStack(spacing: NomiSpacing.medium) {
            // Close button
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.nomiTextLight)
                        .padding(NomiSpacing.small)
                        .background(Color.nomiCardBackground)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Progress indicator
                Text("\(currentIndex + 1) / \(generatedWords.count)")
                    .font(.nomiCaption())
                    .foregroundColor(.nomiTextLight)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Word card
            let word = generatedWords[currentIndex]
            
            WordCard(
                word: word,
                language: appState.selectedLanguage ?? .japanese,
                isGeneratingImage: isGeneratingImage,
                onSpeak: { speakWord(word) }
            )
            .popIn()
            
            Spacer()
            
            // Action buttons
            VStack(spacing: NomiSpacing.small) {
                KawaiiButton(title: "Add to Journal", icon: "📔", style: .primary) {
                    addToJournal(word)
                }
                
                HStack(spacing: NomiSpacing.small) {
                    KawaiiButton(title: "Skip", style: .outline) {
                        nextWord()
                    }
                    
                    KawaiiButton(title: "I know this", style: .ghost) {
                        nextWord()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, NomiSpacing.large)
        }
    }
    
    // MARK: - Summary View
    
    private var summaryView: some View {
        VStack(spacing: NomiSpacing.large) {
            Spacer()
            
            // Celebration
            Text("🎉")
                .font(.system(size: 80))
                .floating()
            
            VStack(spacing: NomiSpacing.small) {
                Text("Great job!")
                    .font(.nomiTitle())
                    .foregroundColor(.nomiTextDark)
                
                Text("You collected \(collectedCount) new sticker\(collectedCount == 1 ? "" : "s")!")
                    .font(.nomiBody())
                    .foregroundColor(.nomiTextLight)
            }
            
            // Collected stickers preview
            if collectedCount > 0 {
                HStack(spacing: -20) {
                    ForEach(0..<min(collectedCount, 5), id: \.self) { index in
                        Circle()
                            .fill(Color(hex: location.themeColor).opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(location.icon)
                                    .font(.system(size: 24))
                            )
                            .popIn(delay: Double(index) * 0.1)
                    }
                }
                .padding(.vertical)
            }
            
            Spacer()
            
            KawaiiButton(title: "Back to Journal", icon: "📔") {
                dismiss()
            }
            .padding(.horizontal, NomiSpacing.large)
            .padding(.bottom, NomiSpacing.huge)
        }
    }
    
    // MARK: - Actions
    
    private func loadWords() {
        print("🔵 [LearnSession] loadWords() CALLED")
        NSLog("🔵 [LearnSession] loadWords() CALLED")
        Task { @MainActor in
            let language = appState.selectedLanguage ?? .japanese
            
            // Log for debugging
            print("🔵 [LearnSession] location: \(location.rawValue), language: \(language.rawValue)")
            NSLog("🔵 [LearnSession] location: %@, language: %@", location.rawValue, language.rawValue)
            print("🔵 [LearnSession] currentJournal is nil: \(appState.currentJournal == nil)")
            NSLog("🔵 [LearnSession] currentJournal is nil: %@", appState.currentJournal == nil ? "true" : "false")
            logger.info("loadWords called for location: \(location.rawValue), language: \(language.rawValue)")
            logger.info("currentJournal is nil: \(appState.currentJournal == nil)")
            
            // Get existing words to exclude
            let existingWords = Set(appState.currentJournal?.stickerWords
                .filter { $0.locationId == location.id }
                .map { $0.englishWord.lowercased() } ?? [])
            
            logger.info("Existing words: \(existingWords.count)")
            print("🔵 [LearnSession] Existing words: \(existingWords.count)")
            NSLog("🔵 [LearnSession] Existing words: %d", existingWords.count)
            
            // First, try to use predefined vocabulary
            let predefinedWords = PredefinedVocabulary.words(for: language, location: location)
            logger.info("Predefined words available: \(predefinedWords.count)")
            print("🔵 [LearnSession] Predefined words available: \(predefinedWords.count)")
            NSLog("🔵 [LearnSession] Predefined words available: %d", predefinedWords.count)
            
            let filteredWords = predefinedWords.filter { !existingWords.contains($0.englishWord.lowercased()) }
            logger.info("Filtered words: \(filteredWords.count)")
            print("🔵 [LearnSession] Filtered words: \(filteredWords.count)")
            NSLog("🔵 [LearnSession] Filtered words: %d", filteredWords.count)
            
            if !filteredWords.isEmpty {
                // Use predefined words (no API call needed!)
                let wordsToShow = Array(filteredWords.prefix(Config.maxWordsPerSession))
                
                // We're already on MainActor, so just set directly
                generatedWords = wordsToShow.map { predefined in
                    // Load bundled sticker image if available
                    var imageData: Data? = nil
                    if let assetName = predefined.stickerAsset,
                       let image = UIImage(named: assetName) {
                        imageData = image.pngData()
                    }
                    
                    return GeneratedWord(
                        targetWord: predefined.targetWord,
                        romanization: predefined.romanization,
                        englishWord: predefined.englishWord,
                        exampleSentence: predefined.exampleSentence,
                        stickerImageData: imageData,
                        stickerEmoji: predefined.stickerEmoji
                    )
                }
                logger.info("Set \(generatedWords.count) generated words, setting isLoading=false")
                print("🔵 [LearnSession] Set \(generatedWords.count) generated words, isLoading=false")
                NSLog("🔵 [LearnSession] Set %d generated words, isLoading=false", generatedWords.count)
                isLoading = false
            } else {
                logger.info("No predefined words available, falling back to AI")
                print("🔵 [LearnSession] No predefined words, falling back to AI")
                NSLog("🔵 [LearnSession] No predefined words, falling back to AI")
                // Fall back to AI generation if no predefined words available
                await generateWordsFromAI(existingWords: Array(existingWords))
            }
        }
    }
    
    @MainActor
    private func generateWordsFromAI(existingWords: [String]) async {
        logger.info("Generating words from AI...")
        do {
            let words = try await OpenAIService.shared.generateWords(
                language: appState.selectedLanguage ?? .japanese,
                location: location,
                count: Config.maxWordsPerSession,
                excludeWords: existingWords
            )
            
            logger.info("AI generated \(words.count) words")
            
            generatedWords = words
            isLoading = false
            
            // Start generating image for first word
            if !words.isEmpty {
                generateImageForCurrentWord()
            }
        } catch {
            logger.error("AI generation failed: \(error.localizedDescription)")
            self.error = error.localizedDescription
            isLoading = false
        }
    }
    
    private func generateImageForCurrentWord() {
        guard currentIndex < generatedWords.count, Config.enableImageGeneration else { return }
        
        isGeneratingImage = true
        let word = generatedWords[currentIndex]
        
        Task {
            do {
                let imageData = try await OpenAIService.shared.generateStickerImage(
                    for: word.targetWord,
                    englishMeaning: word.englishWord
                )
                
                await MainActor.run {
                    if currentIndex < generatedWords.count {
                        generatedWords[currentIndex].stickerImageData = imageData
                    }
                    isGeneratingImage = false
                }
            } catch {
                await MainActor.run {
                    isGeneratingImage = false
                }
                print("Failed to generate image: \(error)")
            }
        }
    }
    
    private func addToJournal(_ word: GeneratedWord) {
        guard let journal = appState.currentJournal else { return }
        
        HapticService.shared.collect()
        
        let sticker = StickerWord(
            journalId: journal.id,
            locationId: location.id,
            targetWord: word.targetWord,
            romanization: word.romanization,
            englishWord: word.englishWord,
            exampleSentence: word.exampleSentence,
            stickerImageData: word.stickerImageData,
            stickerEmoji: word.stickerEmoji
        )
        sticker.journal = journal
        
        modelContext.insert(sticker)
        
        do {
            try modelContext.save()
            collectedCount += 1
        } catch {
            print("Failed to save sticker: \(error)")
        }
        
        nextWord()
    }
    
    private func nextWord() {
        HapticService.shared.tap()
        
        withAnimation(.nomiBounce) {
            currentIndex += 1
        }
        
        if currentIndex >= generatedWords.count {
            showSummary = true
            HapticService.shared.success()
        } else {
            // Generate image for next word
            generateImageForCurrentWord()
        }
    }
    
    private func speakWord(_ word: GeneratedWord) {
        guard let language = appState.selectedLanguage else { return }
        audioService.speak(word.targetWord, language: language)
    }
}

// MARK: - Word Card

struct WordCard: View {
    let word: GeneratedWord
    let language: Language
    let isGeneratingImage: Bool
    let onSpeak: () -> Void
    
    @StateObject private var audioService = AudioService.shared
    
    var body: some View {
        VStack(spacing: NomiSpacing.large) {
            // Sticker image
            ZStack {
                Circle()
                    .fill(Color.nomiPink.opacity(0.15))
                    .frame(width: 180, height: 180)
                
                if isGeneratingImage {
                    VStack(spacing: NomiSpacing.small) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .nomiPink))
                        Text("Creating sticker...")
                            .font(.nomiCaption())
                            .foregroundColor(.nomiTextLight)
                    }
                } else if let imageData = word.stickerImageData,
                          let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                } else if let emoji = word.stickerEmoji {
                    // Show emoji sticker
                    Text(emoji)
                        .font(.system(size: 80))
                } else {
                    Text("✨")
                        .font(.system(size: 60))
                }
            }
            .floating(amplitude: 5, duration: 2.5)
            
            // Word info
            VStack(spacing: NomiSpacing.small) {
                // Target word
                Text(word.targetWord)
                    .font(.nomiWord())
                    .foregroundColor(.nomiTextDark)
                
                // Romanization
                if let romanization = word.romanization {
                    Text(romanization)
                        .font(.nomiSubheadline())
                        .foregroundColor(.nomiTextLight)
                }
                
                // English translation
                Text(word.englishWord)
                    .font(.nomiHeadline())
                    .foregroundColor(.nomiPink)
                
                // Audio button
                Button(action: onSpeak) {
                    HStack(spacing: NomiSpacing.tiny) {
                        Image(systemName: audioService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                        Text("Listen")
                    }
                    .font(.nomiCaption())
                    .foregroundColor(.nomiPink)
                    .padding(.horizontal, NomiSpacing.medium)
                    .padding(.vertical, NomiSpacing.small)
                    .background(Color.nomiPink.opacity(0.1))
                    .cornerRadius(NomiRadius.medium)
                }
                .bouncePress()
            }
            
            // Example sentence (expandable)
            if let example = word.exampleSentence {
                VStack(spacing: NomiSpacing.tiny) {
                    Text("Example")
                        .font(.nomiCaption())
                        .foregroundColor(.nomiTextLight)
                    
                    Text(example)
                        .font(.nomiBody())
                        .foregroundColor(.nomiText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color.nomiCream)
                .cornerRadius(NomiRadius.medium)
            }
        }
        .padding()
        .background(Color.nomiCardBackground)
        .cornerRadius(NomiRadius.extraLarge)
        .nomiShadow(radius: 20, y: 10)
        .padding(.horizontal)
    }
}

#Preview {
    LearnSessionView(location: .cafe)
        .environment(AppState())
        .modelContainer(for: [User.self, Journal.self, StickerWord.self], inMemory: true)
}
