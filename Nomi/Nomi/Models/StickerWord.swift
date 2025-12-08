//
//  StickerWord.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import Foundation
import SwiftData

@Model
final class StickerWord {
    @Attribute(.unique) var id: UUID
    var journalId: UUID
    var locationId: String
    var targetWord: String
    var romanization: String?
    var englishWord: String
    var exampleSentence: String?
    var stickerImageURL: String?
    var stickerImageData: Data?
    var stickerEmoji: String? // Fallback emoji when no image is available
    var audioURL: String?
    var masteryLevel: Int
    var lastReviewedAt: Date?
    var collectedAt: Date
    var timesReviewed: Int
    var consecutiveCorrect: Int
    
    // Position in journal for organic layout
    var positionX: Double
    var positionY: Double
    var rotation: Double
    
    var journal: Journal?
    
    init(
        id: UUID = UUID(),
        journalId: UUID,
        locationId: String,
        targetWord: String,
        romanization: String? = nil,
        englishWord: String,
        exampleSentence: String? = nil,
        stickerImageURL: String? = nil,
        stickerImageData: Data? = nil,
        stickerEmoji: String? = nil,
        masteryLevel: Int = 1,
        collectedAt: Date = Date()
    ) {
        self.id = id
        self.journalId = journalId
        self.locationId = locationId
        self.targetWord = targetWord
        self.romanization = romanization
        self.englishWord = englishWord
        self.exampleSentence = exampleSentence
        self.stickerImageURL = stickerImageURL
        self.stickerImageData = stickerImageData
        self.stickerEmoji = stickerEmoji
        self.masteryLevel = masteryLevel
        self.collectedAt = collectedAt
        self.timesReviewed = 0
        self.consecutiveCorrect = 0
        
        // Random position for organic layout
        self.positionX = Double.random(in: 0.1...0.9)
        self.positionY = Double.random(in: 0.1...0.9)
        self.rotation = Double.random(in: -15...15)
    }
    
    var location: Location? {
        Location.allCases.first { $0.id == locationId }
    }
    
    var isMastered: Bool {
        masteryLevel >= 5
    }
    
    func markCorrect() {
        consecutiveCorrect += 1
        timesReviewed += 1
        lastReviewedAt = Date()
        
        // Increase mastery every 2 consecutive correct answers
        if consecutiveCorrect >= 2 && masteryLevel < 5 {
            masteryLevel += 1
            consecutiveCorrect = 0
        }
    }
    
    func markIncorrect() {
        consecutiveCorrect = 0
        timesReviewed += 1
        lastReviewedAt = Date()
        
        // Decrease mastery but not below 1
        if masteryLevel > 1 {
            masteryLevel -= 1
        }
    }
    
    // Priority score for spaced repetition (lower = higher priority)
    var revisionPriority: Double {
        let masteryWeight = Double(6 - masteryLevel) * 10
        let timeWeight: Double
        
        if let lastReview = lastReviewedAt {
            let hoursSinceReview = Date().timeIntervalSince(lastReview) / 3600
            timeWeight = min(hoursSinceReview, 168) // Cap at 1 week
        } else {
            timeWeight = 168 // Never reviewed = high priority
        }
        
        return masteryWeight + timeWeight
    }
}
