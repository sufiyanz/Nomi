//
//  NotificationService.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifier = "com.nomi.daily-reminder"
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.isAuthorized = granted
                self.authorizationStatus = granted ? .authorized : .denied
            }
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        await MainActor.run {
            self.authorizationStatus = settings.authorizationStatus
            self.isAuthorized = settings.authorizationStatus == .authorized
        }
    }
    
    // MARK: - Daily Reminder
    
    func scheduleDailyReminder(at hour: Int, minute: Int) async {
        // Remove existing reminder first
        await cancelDailyReminder()
        
        // Check authorization
        if !isAuthorized {
            let granted = await requestAuthorization()
            if !granted { return }
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = randomReminderTitle()
        content.body = randomReminderBody()
        content.sound = .default
        content.badge = 1
        
        // Create daily trigger
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        // Create and add request
        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Daily reminder scheduled for \(hour):\(minute)")
        } catch {
            print("Failed to schedule daily reminder: \(error)")
        }
    }
    
    func cancelDailyReminder() async {
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }
    
    func isReminderScheduled() async -> Bool {
        let requests = await center.pendingNotificationRequests()
        return requests.contains { $0.identifier == reminderIdentifier }
    }
    
    // MARK: - Clear Badge
    
    func clearBadge() async {
        do {
            try await center.setBadgeCount(0)
        } catch {
            print("Failed to clear badge: \(error)")
        }
    }
    
    // MARK: - Random Messages
    
    private func randomReminderTitle() -> String {
        let titles = [
            "Time to learn! 🌸",
            "Your journal awaits! ✨",
            "New words are waiting! 📚",
            "Let's collect stickers! 🎀",
            "Learning time! 🌟"
        ]
        return titles.randomElement() ?? titles[0]
    }
    
    private func randomReminderBody() -> String {
        let bodies = [
            "Collect new words and grow your vocabulary garden!",
            "Just 5 minutes of learning makes a big difference!",
            "Your kawaii stickers miss you! Come say hello!",
            "A new word a day keeps forgetting away!",
            "Open your journal and discover something new today!"
        ]
        return bodies.randomElement() ?? bodies[0]
    }
}
