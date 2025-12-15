//
//  Journal.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import Foundation
import SwiftData

@Model
final class Journal {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var languageCode: String
    var createdAt: Date
    var lastOpenedAt: Date
    
    var user: User?
    
    @Relationship(deleteRule: .cascade, inverse: \StickerWord.journal)
    var stickerWords: [StickerWord] = []
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        languageCode: String,
        createdAt: Date = Date(),
        lastOpenedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.languageCode = languageCode
        self.createdAt = createdAt
        self.lastOpenedAt = lastOpenedAt
    }
    
    var language: Language? {
        Language.allCases.first { $0.code == languageCode }
    }
    
    func wordCount(for location: Location) -> Int {
        stickerWords.filter { $0.locationId == location.id }.count
    }
    
    var totalWordCount: Int {
        stickerWords.count
    }
    
    func updateLastOpened() {
        lastOpenedAt = Date()
    }
}
