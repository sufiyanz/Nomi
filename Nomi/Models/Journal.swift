import Foundation
import SwiftData

// MARK: - Journal (for future use)

/// Represents a user's learning journal entry
@Model
final class Journal {
    @Attribute(.unique) var id: String
    var date: Date
    var wordsLearned: Int
    var wordsReviewed: Int
    var timeSpentSeconds: Int
    var notes: String?
    
    init(
        date: Date = Date(),
        wordsLearned: Int = 0,
        wordsReviewed: Int = 0,
        timeSpentSeconds: Int = 0,
        notes: String? = nil
    ) {
        self.id = UUID().uuidString
        self.date = date
        self.wordsLearned = wordsLearned
        self.wordsReviewed = wordsReviewed
        self.timeSpentSeconds = timeSpentSeconds
        self.notes = notes
    }
}
