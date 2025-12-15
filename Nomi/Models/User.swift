//
//  User.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var appleUserIdentifier: String
    var email: String?
    var createdAt: Date
    var lastActiveAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Journal.user)
    var journals: [Journal] = []
    
    // Notification settings
    var notificationsEnabled: Bool = false
    var reminderHour: Int = 9
    var reminderMinute: Int = 0
    
    init(
        id: UUID = UUID(),
        appleUserIdentifier: String,
        email: String? = nil,
        createdAt: Date = Date(),
        lastActiveAt: Date = Date()
    ) {
        self.id = id
        self.appleUserIdentifier = appleUserIdentifier
        self.email = email
        self.createdAt = createdAt
        self.lastActiveAt = lastActiveAt
    }
    
    func updateLastActive() {
        lastActiveAt = Date()
    }
}
