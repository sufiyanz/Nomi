import Foundation
import UserNotifications

// MARK: - Notification Service

@MainActor
class NotificationService: ObservableObject {
    
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let center = UNUserNotificationCenter.current()
    private let dailyReminderIdentifier = "nomi.daily.reminder"
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Public Methods
    
    /// Requests notification permissions
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    /// Schedules a daily reminder notification
    func scheduleDailyReminder(at time: Date) async {
        guard Config.Features.enableNotifications else { return }
        
        // Cancel existing reminder first
        await cancelDailyReminder()
        
        // Create content
        let content = UNMutableNotificationContent()
        content.title = "Time to learn!"
        content.body = "Open Nomi and collect a new word today 🌟"
        content.sound = .default
        
        // Create trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Daily reminder scheduled for \(components.hour ?? 0):\(components.minute ?? 0)")
        } catch {
            print("Failed to schedule daily reminder: \(error)")
        }
    }
    
    /// Cancels the daily reminder notification
    func cancelDailyReminder() async {
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
    }
    
    /// Checks if daily reminder is currently scheduled
    func isDailyReminderScheduled() async -> Bool {
        let requests = await center.pendingNotificationRequests()
        return requests.contains { $0.identifier == dailyReminderIdentifier }
    }
    
    // MARK: - Private Methods
    
    private func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }
}
