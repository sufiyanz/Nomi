//
//  RevisionSessionView.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import SwiftUI
import SwiftData

struct RevisionSessionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let location: Location
    
    @State private var cardsToReview: [StickerWord] = []
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var correctCount = 0
    @State private var showSummary = false
    @State private var newlyMasteredCount = 0
    
    @StateObject private var audioService = AudioService.shared
    
    var body: some View {
        ZStack {
            LinearGradient.nomiBackground
                .ignoresSafeArea()
            
            if showSummary {
                summaryView
            } else if currentIndex < cardsToReview.count {
                flashcardView
            }
        }
        .onAppear {
            loadCardsForReview()
        }
    }
    
    // MARK: - Flashcard View
    
    private var flashcardView: some View {
        VStack(spacing: NomiSpacing.medium) {
            // Header
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
                
                // Progress
                HStack(spacing: NomiSpacing.tiny) {
                    Text("\(currentIndex + 1)")
                        .foregroundColor(.nomiPink)
                    Text("/")
                        .foregroundColor(.nomiTextLight)
                    Text("\(cardsToReview.count)")
                        .foregroundColor(.nomiTextLight)
                }
                .font(.nomiSubheadline())
            }
            .padding(.horizontal)
            
            // Progress bar
            ProgressView(value: Double(currentIndex), total: Double(cardsToReview.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .nomiPink))
                .padding(.horizontal)
            
            Spacer()
            
            // Flashcard
            let card = cardsToReview[currentIndex]
            
            FlashcardView(
                stickerWord: card,
                isFlipped: $isFlipped,
                onSpeak: { speakWord(card) }
            )
            .onTapGesture {
                if !isFlipped {
                    flipCard()
                }
            }
            
            Spacer()
            
            // Action buttons (shown after flip)
            if isFlipped {
                HStack(spacing: NomiSpacing.medium) {
                    KawaiiButton(title: "Still learning", icon: "🔄", style: .outline) {
                        markIncorrect()
                    }
                    
                    KawaiiButton(title: "Got it!", icon: "✓", style: .primary) {
                        markCorrect()
                    }
                }
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Text("Tap the card to reveal")
                    .font(.nomiCaption())
                    .foregroundColor(.nomiTextLight)
            }
            
            Spacer()
                .frame(height: NomiSpacing.large)
        }
    }
    
    // MARK: - Summary View
    
    private var summaryView: some View {
        VStack(spacing: NomiSpacing.large) {
            Spacer()
            
            // Celebration
            Text(correctCount > cardsToReview.count / 2 ? "🌟" : "💪")
                .font(.system(size: 80))
                .floating()
            
            VStack(spacing: NomiSpacing.small) {
                Text(summaryTitle)
                    .font(.nomiTitle())
                    .foregroundColor(.nomiTextDark)
                
                Text("\(correctCount) out of \(cardsToReview.count) correct")
                    .font(.nomiBody())
                    .foregroundColor(.nomiTextLight)
            }
            
            // Stats
            HStack(spacing: NomiSpacing.extraLarge) {
                VStack(spacing: NomiSpacing.tiny) {
                    Text("\(correctCount)")
                        .font(.nomiLarge())
                        .foregroundColor(.nomiSuccess)
                    Text("Correct")
                        .font(.nomiCaption())
                        .foregroundColor(.nomiTextLight)
                }
                
                VStack(spacing: NomiSpacing.tiny) {
                    Text("\(cardsToReview.count - correctCount)")
                        .font(.nomiLarge())
                        .foregroundColor(.nomiWarning)
                    Text("To Review")
                        .font(.nomiCaption())
                        .foregroundColor(.nomiTextLight)
                }
                
                if newlyMasteredCount > 0 {
                    VStack(spacing: NomiSpacing.tiny) {
                        Text("\(newlyMasteredCount)")
                            .font(.nomiLarge())
                            .foregroundColor(.nomiPink)
                        Text("Mastered!")
                            .font(.nomiCaption())
                            .foregroundColor(.nomiTextLight)
                    }
                }
            }
            .padding()
            .background(Color.nomiCardBackground)
            .cornerRadius(NomiRadius.large)
            
            Spacer()
            
            VStack(spacing: NomiSpacing.small) {
                if cardsToReview.count - correctCount > 0 {
                    KawaiiButton(title: "Review Again", icon: "🔄", style: .secondary) {
                        resetSession()
                    }
                }
                
                KawaiiButton(title: "Done", icon: "✨") {
                    dismiss()
                }
            }
            .padding(.horizontal, NomiSpacing.large)
            .padding(.bottom, NomiSpacing.huge)
        }
    }
    
    // MARK: - Computed Properties
    
    private var summaryTitle: String {
        let percentage = Double(correctCount) / Double(cardsToReview.count)
        switch percentage {
        case 0.9...1.0: return "Perfect!"
        case 0.7..<0.9: return "Great job!"
        case 0.5..<0.7: return "Good effort!"
        default: return "Keep practicing!"
        }
    }
    
    // MARK: - Actions
    
    private func loadCardsForReview() {
        guard let journal = appState.currentJournal else { return }
        
        // Get words for this location, sorted by revision priority
        let locationWords = journal.stickerWords
            .filter { $0.locationId == location.id }
            .sorted { $0.revisionPriority > $1.revisionPriority }
        
        // Take up to 10 words for review
        cardsToReview = Array(locationWords.prefix(10))
    }
    
    private func flipCard() {
        HapticService.shared.flip()
        withAnimation(.nomiBounce) {
            isFlipped = true
        }
    }
    
    private func markCorrect() {
        let card = cardsToReview[currentIndex]
        let wasMastered = card.isMastered
        
        card.markCorrect()
        
        if !wasMastered && card.isMastered {
            newlyMasteredCount += 1
        }
        
        HapticService.shared.correct()
        correctCount += 1
        
        try? modelContext.save()
        nextCard()
    }
    
    private func markIncorrect() {
        let card = cardsToReview[currentIndex]
        card.markIncorrect()
        
        HapticService.shared.incorrect()
        
        try? modelContext.save()
        nextCard()
    }
    
    private func nextCard() {
        withAnimation(.nomiBounce) {
            isFlipped = false
            currentIndex += 1
        }
        
        if currentIndex >= cardsToReview.count {
            showSummary = true
            HapticService.shared.success()
        }
    }
    
    private func resetSession() {
        currentIndex = 0
        correctCount = 0
        newlyMasteredCount = 0
        isFlipped = false
        showSummary = false
        loadCardsForReview()
    }
    
    private func speakWord(_ word: StickerWord) {
        guard let language = appState.selectedLanguage else { return }
        audioService.speak(word.targetWord, language: language)
    }
}

// MARK: - Flashcard View

struct FlashcardView: View {
    let stickerWord: StickerWord
    @Binding var isFlipped: Bool
    let onSpeak: () -> Void
    
    var body: some View {
        ZStack {
            // Back of card (English)
            cardBack
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : 180),
                    axis: (x: 0, y: 1, z: 0)
                )
                .opacity(isFlipped ? 1 : 0)
            
            // Front of card (Target language)
            cardFront
                .rotation3DEffect(
                    .degrees(isFlipped ? -180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                .opacity(isFlipped ? 0 : 1)
        }
        .animation(.nomiSoft, value: isFlipped)
    }
    
    private var cardFront: some View {
        VStack(spacing: NomiSpacing.large) {
            // Sticker
            ZStack {
                Circle()
                    .fill(Color(hex: stickerWord.location?.themeColor ?? "#FFB6C1").opacity(0.2))
                    .frame(width: 140, height: 140)
                
                if let imageData = stickerWord.stickerImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                } else if let emoji = stickerWord.stickerEmoji {
                    // Show saved emoji sticker
                    Text(emoji)
                        .font(.system(size: 70))
                } else {
                    Text(stickerWord.location?.icon ?? "✨")
                        .font(.system(size: 50))
                }
            }
            
            // Target word
            Text(stickerWord.targetWord)
                .font(.nomiWord())
                .foregroundColor(.nomiTextDark)
            
            // Romanization
            if let romanization = stickerWord.romanization {
                Text(romanization)
                    .font(.nomiSubheadline())
                    .foregroundColor(.nomiTextLight)
            }
            
            // Audio button
            Button(action: onSpeak) {
                HStack(spacing: NomiSpacing.tiny) {
                    Image(systemName: "speaker.wave.2.fill")
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
            
            // Mastery level
            MasteryIndicator(level: stickerWord.masteryLevel)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, NomiSpacing.extraLarge)
        .padding(.horizontal)
        .background(Color.nomiCardBackground)
        .cornerRadius(NomiRadius.extraLarge)
        .nomiShadow(radius: 20, y: 10)
        .padding(.horizontal)
    }
    
    private var cardBack: some View {
        VStack(spacing: NomiSpacing.large) {
            Text("💡")
                .font(.system(size: 50))
            
            // English word
            Text(stickerWord.englishWord)
                .font(.nomiTitle())
                .foregroundColor(.nomiPink)
            
            // Target word reminder
            VStack(spacing: NomiSpacing.tiny) {
                Text(stickerWord.targetWord)
                    .font(.nomiHeadline())
                    .foregroundColor(.nomiTextDark)
                
                if let romanization = stickerWord.romanization {
                    Text(romanization)
                        .font(.nomiCaption())
                        .foregroundColor(.nomiTextLight)
                }
            }
            
            // Example sentence
            if let example = stickerWord.exampleSentence {
                VStack(spacing: NomiSpacing.tiny) {
                    Text("Example")
                        .font(.nomiCaption())
                        .foregroundColor(.nomiTextLight)
                    
                    Text(example)
                        .font(.nomiBody())
                        .foregroundColor(.nomiText)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.nomiCream)
                .cornerRadius(NomiRadius.medium)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, NomiSpacing.extraLarge)
        .padding(.horizontal)
        .background(Color.nomiCardBackground)
        .cornerRadius(NomiRadius.extraLarge)
        .nomiShadow(radius: 20, y: 10)
        .padding(.horizontal)
    }
}

#Preview {
    RevisionSessionView(location: .cafe)
        .environment(AppState())
        .modelContainer(for: [User.self, Journal.self, StickerWord.self], inMemory: true)
}
