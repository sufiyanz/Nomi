import SwiftUI
import SwiftData

// MARK: - Preview Helpers

#if DEBUG

extension AppState {
    static var preview: AppState {
        let state = AppState()
        state.isAuthenticated = true
        state.currentLanguage = .japanese
        state.streakCount = 5
        return state
    }
}

@MainActor
func createPreviewContainer() -> ModelContainer {
    let schema = Schema([
        User.self,
        StickerWord.self,
        Journal.self
    ])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    
    do {
        let container = try ModelContainer(for: schema, configurations: [config])
        
        // Add sample data
        let context = container.mainContext
        
        // Sample sticker words
        let sampleWords = [
            StickerWord(wordKey: "coffee", location: .cafe, positionX: 0.3, positionY: 0.3),
            StickerWord(wordKey: "croissant", location: .cafe, positionX: 0.6, positionY: 0.4),
            StickerWord(wordKey: "tea", location: .cafe, positionX: 0.5, positionY: 0.7)
        ]
        
        for word in sampleWords {
            context.insert(word)
        }
        
        // Mark one as collected
        sampleWords[0].collect()
        
        return container
    } catch {
        fatalError("Failed to create preview ModelContainer: \(error)")
    }
}

// MARK: - Preview StickerWord

extension StickerWord {
    static var preview: StickerWord {
        let word = StickerWord(
            wordKey: "coffee_cup",
            location: .cafe,
            positionX: 0.5,
            positionY: 0.5
        )
        return word
    }
    
    static var collectedPreview: StickerWord {
        let word = StickerWord(
            wordKey: "croissant",
            location: .cafe,
            positionX: 0.3,
            positionY: 0.6
        )
        word.collect()
        return word
    }
}

// MARK: - Preview GeneratedWord

extension GeneratedWord {
    static var preview: GeneratedWord {
        GeneratedWord(
            wordKey: "coffee_cup",
            englishWord: "Coffee Cup",
            languageCode: "ja",
            translatedWord: "コーヒーカップ",
            romanization: "Kōhī Kappu",
            exampleSentence: "コーヒーカップを取ってください。",
            exampleRomanization: "Kōhī kappu o totte kudasai.",
            exampleTranslation: "Please hand me the coffee cup."
        )
    }
}

#endif
