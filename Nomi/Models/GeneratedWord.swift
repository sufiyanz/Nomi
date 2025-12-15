import Foundation

// MARK: - Generated Word

/// Represents LLM-generated translation content for a word
struct GeneratedWord: Codable, Identifiable {
    var id: String { "\(wordKey)_\(languageCode)" }
    
    let wordKey: String
    let englishWord: String
    let languageCode: String
    
    // Translated content
    let translatedWord: String
    let romanization: String?
    let exampleSentence: String
    let exampleRomanization: String?
    let exampleTranslation: String
    
    init(
        wordKey: String,
        englishWord: String,
        languageCode: String,
        translatedWord: String,
        romanization: String? = nil,
        exampleSentence: String,
        exampleRomanization: String? = nil,
        exampleTranslation: String
    ) {
        self.wordKey = wordKey
        self.englishWord = englishWord
        self.languageCode = languageCode
        self.translatedWord = translatedWord
        self.romanization = romanization
        self.exampleSentence = exampleSentence
        self.exampleRomanization = exampleRomanization
        self.exampleTranslation = exampleTranslation
    }
}

// MARK: - OpenAI Response Models

struct OpenAITranslationResponse: Codable {
    let translatedWord: String
    let romanization: String?
    let exampleSentence: String
    let exampleRomanization: String?
    let exampleTranslation: String
}
