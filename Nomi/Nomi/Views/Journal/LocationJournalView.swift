//
//  LocationJournalView.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import SwiftUI
import SwiftData

struct LocationJournalView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    
    let location: Location
    
    @State private var showRevisionSession = false
    @State private var selectedJournalSticker: StickerWord?
    @State private var canvasWords: [CanvasWord] = []
    @State private var journalSheetDetent: PresentationDetent = .height(100)
    @State private var showJournalSheet = false
    
    // Set of collected word IDs for quick lookup
    private var collectedWordIds: Set<String> {
        Set(collectedWords.map { $0.englishWord.lowercased() })
    }
    
    // Words already in journal for this location
    private var collectedWords: [StickerWord] {
        appState.currentJournal?.stickerWords.filter { $0.locationId == location.id } ?? []
    }
    
    var body: some View {
        // Canvas area (full screen)
        WordCanvasView(
            words: $canvasWords,
            collectedWords: collectedWordIds,
            location: location,
            language: appState.selectedLanguage ?? .japanese,
            onCollectWord: { word in
                addToJournal(word)
                // Update the collected state
                if let index = canvasWords.firstIndex(where: { $0.id == word.id }) {
                    canvasWords[index] = CanvasWord(
                        predefined: word.predefined,
                        collected: true,
                        position: word.position
                    )
                }
                // Show journal sheet when first word is collected
                if !showJournalSheet && collectedWords.count >= 1 {
                    showJournalSheet = true
                }
            }
        )
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: NomiSpacing.tiny) {
                    Text(location.icon)
                    Text("\(collectedWords.count)/\(canvasWords.count) collected")
                        .font(.nomiCaption())
                        .foregroundColor(.nomiTextLight)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if collectedWords.count >= Config.minWordsForRevision {
                    Button {
                        showRevisionSession = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("📖")
                            Text("Revise")
                                .font(.nomiCaption())
                        }
                        .foregroundColor(.nomiPink)
                    }
                }
            }
        }
        .onAppear {
            initializeCanvasWords()
            // Show journal sheet if there are already collected words
            if !collectedWords.isEmpty {
                showJournalSheet = true
            }
        }
        .fullScreenCover(isPresented: $showRevisionSession) {
            RevisionSessionView(location: location)
        }
        .sheet(item: $selectedJournalSticker) { sticker in
            StickerDetailView(stickerWord: sticker)
        }
        .sheet(isPresented: $showJournalSheet) {
            JournalSheetView(
                collectedWords: collectedWords,
                location: location,
                onSelectSticker: { sticker in
                    selectedJournalSticker = sticker
                }
            )
            .presentationDetents([.height(56), .medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled(upThrough: .large))
            .interactiveDismissDisabled()
            .presentationCornerRadius(20)
        }
    }
    
    // MARK: - Initialize Canvas Words with Scattered Positions
    
    private func initializeCanvasWords() {
        guard canvasWords.isEmpty else { return }
        
        let language = appState.selectedLanguage ?? .japanese
        let predefinedWords = PredefinedVocabulary.words(for: language, location: location)
        let collectedIds = collectedWordIds
        
        // Create scattered positions for each word
        canvasWords = predefinedWords.enumerated().map { index, word in
            // Scatter stickers in a natural pattern
            let position = generateStickerPosition(for: index, total: predefinedWords.count)
            
            return CanvasWord(
                predefined: word,
                collected: collectedIds.contains(word.englishWord.lowercased()),
                position: position
            )
        }
    }
    
    /// Generate a scattered but balanced position for stickers
    private func generateStickerPosition(for index: Int, total: Int) -> CGPoint {
        // Create a spiral-like scattered pattern
        let angle = Double(index) * (2.3998) // Golden angle for natural distribution
        let radius = 60.0 + Double(index) * 35.0 // Increasing radius
        
        let x = cos(angle) * radius
        let y = sin(angle) * radius - 80 // Offset up slightly
        
        // Add some randomness
        let offsetX = Double.random(in: -20...20)
        let offsetY = Double.random(in: -20...20)
        
        return CGPoint(x: x + offsetX, y: y + offsetY)
    }
    
    // MARK: - Actions
    
    private func addToJournal(_ word: CanvasWord) {
        guard let journal = appState.currentJournal else { return }
        
        // Check if already collected
        if collectedWordIds.contains(word.englishWord.lowercased()) {
            return
        }
        
        let sticker = StickerWord(
            journalId: journal.id,
            locationId: location.id,
            targetWord: word.targetWord,
            romanization: word.romanization,
            englishWord: word.englishWord,
            exampleSentence: word.exampleSentence,
            stickerImageData: nil,
            stickerEmoji: word.stickerEmoji
        )
        sticker.journal = journal
        
        modelContext.insert(sticker)
        
        do {
            try modelContext.save()
            HapticService.shared.success()
        } catch {
            print("Failed to save sticker: \(error)")
        }
    }
}

// MARK: - Journal Sheet View (Draggable sheet with all collected words)

struct JournalSheetView: View {
    let collectedWords: [StickerWord]
    let location: Location
    let onSelectSticker: (StickerWord) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Compact header - always visible, simple design
            HStack(spacing: NomiSpacing.small) {
                Text("📔")
                    .font(.system(size: 18))
                
                Text("Your Journal")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.nomiTextDark)
                
                Spacer()
                
                // Word count
                Text("\(collectedWords.count) words")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.nomiTextLight)
            }
            .padding(.horizontal, NomiSpacing.medium)
            .padding(.vertical, 10)
            
            // Divider and expanded content
            Divider()
            
            if collectedWords.isEmpty {
                // Empty state
                VStack(spacing: NomiSpacing.medium) {
                    Text("✨")
                        .font(.system(size: 50))
                    Text("No words collected yet")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.nomiTextLight)
                    Text("Tap stickers on the canvas to add words to your journal")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.nomiTextLight)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                // Word list
                ScrollView {
                    LazyVStack(spacing: NomiSpacing.small) {
                        ForEach(collectedWords) { sticker in
                            JournalWordRow(sticker: sticker) {
                                onSelectSticker(sticker)
                            }
                        }
                    }
                    .padding(.horizontal, NomiSpacing.medium)
                    .padding(.vertical, NomiSpacing.medium)
                }
            }
        }
        .background(Color.nomiCardBackground)
    }
}

// MARK: - Journal Word Row (Compact row for journal list)

struct JournalWordRow: View {
    let sticker: StickerWord
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: NomiSpacing.medium) {
                // Sticker emoji/image
                ZStack {
                    Circle()
                        .fill(Color(hex: sticker.location?.themeColor ?? "#FFB6C1").opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    if let imageData = sticker.stickerImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 35, height: 35)
                    } else if let emoji = sticker.stickerEmoji {
                        Text(emoji)
                            .font(.system(size: 26))
                    } else {
                        Text(sticker.location?.icon ?? "✨")
                            .font(.system(size: 22))
                    }
                }
                
                // Word info
                VStack(alignment: .leading, spacing: 2) {
                    Text(sticker.targetWord)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.nomiTextDark)
                    
                    HStack(spacing: NomiSpacing.tiny) {
                        if let romanization = sticker.romanization {
                            Text(romanization)
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.nomiTextLight)
                            Text("•")
                                .foregroundColor(.nomiTextLight)
                        }
                        Text(sticker.englishWord)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.nomiPink)
                    }
                }
                
                Spacer()
                
                // Mastery indicator
                MasteryDots(level: sticker.masteryLevel)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.nomiTextLight)
            }
            .padding(.horizontal, NomiSpacing.medium)
            .padding(.vertical, NomiSpacing.small)
            .background(Color.nomiPaper)
            .cornerRadius(NomiRadius.medium)
        }
        .buttonStyle(BouncePressStyle())
    }
}

// MARK: - Mastery Dots (Compact indicator)

struct MasteryDots: View {
    let level: Int
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(index < level ? Color.nomiMint : Color.gray.opacity(0.2))
                    .frame(width: 6, height: 6)
            }
        }
    }
}

// MARK: - Sticker Detail View

struct StickerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    let stickerWord: StickerWord
    @StateObject private var audioService = AudioService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.nomiBackground
                    .ignoresSafeArea()
                
                VStack(spacing: NomiSpacing.large) {
                    // Large sticker
                    ZStack {
                        Circle()
                            .fill(Color(hex: stickerWord.location?.themeColor ?? "#FFB6C1").opacity(0.2))
                            .frame(width: 200, height: 200)
                        
                        if let imageData = stickerWord.stickerImageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 160, height: 160)
                        } else if let emoji = stickerWord.stickerEmoji {
                            // Show saved emoji sticker
                            Text(emoji)
                                .font(.system(size: 100))
                        } else {
                            Text(stickerWord.location?.icon ?? "✨")
                                .font(.system(size: 80))
                        }
                    }
                    .floating(amplitude: 6, duration: 3)
                    
                    // Word info
                    VStack(spacing: NomiSpacing.small) {
                        HStack(spacing: NomiSpacing.small) {
                            Text(stickerWord.targetWord)
                                .font(.nomiWord())
                                .foregroundColor(.nomiTextDark)
                            
                            Button {
                                speakWord()
                            } label: {
                                Image(systemName: audioService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.nomiPink)
                                    .frame(width: 36, height: 36)
                                    .background(Color.nomiPink.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(BouncePressStyle())
                        }
                        
                        if let romanization = stickerWord.romanization {
                            Text(romanization)
                                .font(.nomiSubheadline())
                                .foregroundColor(.nomiTextLight)
                        }
                        
                        Text(stickerWord.englishWord)
                            .font(.nomiHeadline())
                            .foregroundColor(.nomiPink)
                    }
                    
                    // Example sentence
                    if let example = stickerWord.exampleSentence {
                        VStack(spacing: NomiSpacing.small) {
                            HStack {
                                Text("Example")
                                    .font(.nomiCaption())
                                    .foregroundColor(.nomiTextLight)
                                Spacer()
                                
                                Button {
                                    guard let language = stickerWord.journal?.language else { return }
                                    audioService.speak(example, language: language)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "speaker.wave.2")
                                            .font(.system(size: 12))
                                        Text("Listen")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .foregroundColor(.nomiPink)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.nomiPink.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(BouncePressStyle())
                            }
                            
                            Text(example)
                                .font(.nomiBody())
                                .foregroundColor(.nomiText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(Color.nomiCream)
                        .cornerRadius(NomiRadius.medium)
                        .padding(.horizontal)
                    }
                    
                    // Mastery level
                    VStack(spacing: NomiSpacing.tiny) {
                        Text("Mastery Level")
                            .font(.nomiCaption())
                            .foregroundColor(.nomiTextLight)
                        
                        MasteryIndicator(level: stickerWord.masteryLevel)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.nomiPink)
                }
            }
        }
    }
    
    private func speakWord() {
        guard let language = stickerWord.journal?.language else { return }
        audioService.speak(stickerWord.targetWord, language: language)
    }
}

#Preview {
    NavigationStack {
        LocationJournalView(location: .cafe)
    }
    .environment(AppState())
    .modelContainer(for: [User.self, Journal.self, StickerWord.self], inMemory: true)
}
