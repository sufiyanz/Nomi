import Foundation
import SwiftData

// MARK: - StickerWord

/// Represents a vocabulary word with its sticker and learning state
@Model
final class StickerWord {
    @Attribute(.unique) var id: String
    
    // Word identification
    var wordKey: String // Unique key like "cafe_coffee_cup"
    var location: String // Location rawValue
    
    // Display position on canvas (0-1 normalized coordinates)
    var positionX: Double
    var positionY: Double
    
    // Learning state
    var isCollected: Bool
    var collectedAt: Date?
    
    // Spaced repetition
    var reviewCount: Int
    var lastReviewedAt: Date?
    var difficulty: Int // 0 = not rated, 1 = hard, 2 = okay, 3 = easy
    var nextReviewDate: Date?
    
    // Content - stored per language
    var cachedTranslations: Data? // JSON: [languageCode: TranslationData]
    
    init(
        wordKey: String,
        location: Location,
        positionX: Double,
        positionY: Double
    ) {
        self.id = "\(location.rawValue)_\(wordKey)"
        self.wordKey = wordKey
        self.location = location.rawValue
        self.positionX = positionX
        self.positionY = positionY
        self.isCollected = false
        self.collectedAt = nil
        self.reviewCount = 0
        self.lastReviewedAt = nil
        self.difficulty = 0
        self.nextReviewDate = nil
        self.cachedTranslations = nil
    }
    
    var locationEnum: Location {
        Location(rawValue: location) ?? .home
    }
    
    /// Marks the word as collected
    func collect() {
        guard !isCollected else { return }
        isCollected = true
        collectedAt = Date()
    }
    
    /// Records a review with the given difficulty
    func recordReview(difficulty: ReviewDifficulty) {
        self.difficulty = difficulty.rawValue
        self.reviewCount += 1
        self.lastReviewedAt = Date()
        self.nextReviewDate = calculateNextReviewDate(difficulty: difficulty)
    }
    
    private func calculateNextReviewDate(difficulty: ReviewDifficulty) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // Simple spaced repetition intervals
        let daysToAdd: Int
        switch difficulty {
        case .hard:
            daysToAdd = 1 // Review tomorrow
        case .okay:
            daysToAdd = max(3, reviewCount * 2) // Growing interval
        case .easy:
            daysToAdd = max(7, reviewCount * 4) // Longer interval
        }
        
        return calendar.date(byAdding: .day, value: daysToAdd, to: now) ?? now
    }
}

// MARK: - Review Difficulty

enum ReviewDifficulty: Int, CaseIterable {
    case hard = 1
    case okay = 2
    case easy = 3
    
    var displayName: String {
        switch self {
        case .hard: return "Hard"
        case .okay: return "Okay"
        case .easy: return "Easy"
        }
    }
    
    var emoji: String {
        switch self {
        case .hard: return "👎"
        case .okay: return "😐"
        case .easy: return "👍"
        }
    }
}

// MARK: - Translation Data

struct TranslationData: Codable {
    let word: String
    let romanization: String?
    let exampleSentence: String
    let exampleRomanization: String?
    let exampleTranslation: String
}
