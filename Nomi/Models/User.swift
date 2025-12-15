import Foundation
import SwiftData

// MARK: - User

@Model
final class User {
    @Attribute(.unique) var id: String
    var appleUserID: String
    var email: String?
    var createdAt: Date
    var selectedLanguage: String // Language rawValue
    var streakCount: Int
    var lastActiveDate: Date?
    
    // Notification preferences
    var dailyReminderEnabled: Bool
    var reminderTime: Date
    
    init(
        id: String = UUID().uuidString,
        appleUserID: String,
        email: String? = nil,
        selectedLanguage: Language = .japanese,
        streakCount: Int = 0,
        dailyReminderEnabled: Bool = false,
        reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    ) {
        self.id = id
        self.appleUserID = appleUserID
        self.email = email
        self.createdAt = Date()
        self.selectedLanguage = selectedLanguage.rawValue
        self.streakCount = streakCount
        self.lastActiveDate = nil
        self.dailyReminderEnabled = dailyReminderEnabled
        self.reminderTime = reminderTime
    }
    
    var language: Language {
        get { Language(rawValue: selectedLanguage) ?? .japanese }
        set { selectedLanguage = newValue.rawValue }
    }
    
    /// Updates streak based on learning activity
    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastActive = lastActiveDate {
            let lastActiveDay = calendar.startOfDay(for: lastActive)
            let daysDifference = calendar.dateComponents([.day], from: lastActiveDay, to: today).day ?? 0
            
            if daysDifference == 0 {
                // Same day, streak unchanged
                return
            } else if daysDifference == 1 {
                // Consecutive day, increment streak
                streakCount += 1
            } else {
                // Missed days, reset streak
                streakCount = 1
            }
        } else {
            // First activity
            streakCount = 1
        }
        
        lastActiveDate = Date()
    }
}
