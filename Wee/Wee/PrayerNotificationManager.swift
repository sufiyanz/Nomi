import Foundation
import UserNotifications
import Combine

// MARK: - Prayer Notification Models
struct PrayerNotification {
    let id: String
    let prayer: PrayerName
    let scheduledTime: Date
    let notificationType: PrayerNotificationType
    let isActive: Bool
    
    init(prayer: PrayerName, scheduledTime: Date, type: PrayerNotificationType = .call, isActive: Bool = true) {
        self.id = "\(prayer.rawValue)_\(type.rawValue)_\(scheduledTime.timeIntervalSince1970)"
        self.prayer = prayer
        self.scheduledTime = scheduledTime
        self.notificationType = type
        self.isActive = isActive
    }
}

enum PrayerNotificationType: String, CaseIterable {
    case call = "call"           // At prayer time
    case reminder5 = "reminder5" // 5 minutes before
    case reminder15 = "reminder15" // 15 minutes before
    case reminder30 = "reminder30" // 30 minutes before
    
    var displayName: String {
        switch self {
        case .call:
            return "Prayer Time"
        case .reminder5:
            return "5 minutes before"
        case .reminder15:
            return "15 minutes before"
        case .reminder30:
            return "30 minutes before"
        }
    }
    
    var offsetMinutes: Int {
        switch self {
        case .call:
            return 0
        case .reminder5:
            return -5
        case .reminder15:
            return -15
        case .reminder30:
            return -30
        }
    }
}

enum NotificationSound: String, CaseIterable, Codable {
    case `default` = "default"
    case adhan = "adhan"
    case beep = "beep"
    case bell = "bell"
    case silent = "silent"
    
    var displayName: String {
        switch self {
        case .default:
            return "Default"
        case .adhan:
            return "Adhan"
        case .beep:
            return "Beep"
        case .bell:
            return "Bell"
        case .silent:
            return "Silent"
        }
    }
    
    var soundName: UNNotificationSoundName? {
        switch self {
        case .default:
            return nil // nil means use default system sound
        case .adhan:
            return UNNotificationSoundName("adhan_notification.caf")
        case .beep:
            return UNNotificationSoundName("beep.caf")
        case .bell:
            return UNNotificationSoundName("bell.caf")
        case .silent:
            return nil
        }
    }
}

// MARK: - Prayer Notification Manager
@MainActor
class PrayerNotificationManager: NSObject, ObservableObject {
    static let shared = PrayerNotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isSchedulingNotifications = false
    @Published var lastError: NotificationError?
    @Published var scheduledNotifications: [PrayerNotification] = []
    @Published var notificationSettings = NotificationSettings()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let preferences = NotificationPreferences.shared
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        
        notificationCenter.delegate = self
        loadNotificationSettings()
        checkAuthorizationStatus()
    }
    
    // MARK: - Public Methods
    
    func requestNotificationPermission() async throws {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            authorizationStatus = granted ? .authorized : .denied
            
            if !granted {
                throw NotificationError.permissionDenied
            }
            
        } catch {
            authorizationStatus = .denied
            throw NotificationError.permissionDenied
        }
    }
    
    func scheduleNotifications(for prayerTimes: DailyPrayerTimes) async throws {
        guard authorizationStatus == .authorized else {
            throw NotificationError.permissionDenied
        }
        
        isSchedulingNotifications = true
        lastError = nil
        
        do {
            // Clear existing notifications for the day
            await clearNotifications(for: prayerTimes.date)
            
            var newNotifications: [PrayerNotification] = []
            
            for prayer in prayerTimes.prayers {
                guard prayer.name.isObligatoryPrayer else { continue }
                
                let notificationsForPrayer = try await createNotifications(for: prayer)
                newNotifications.append(contentsOf: notificationsForPrayer)
            }
            
            // Schedule all notifications
            for notification in newNotifications {
                try await scheduleNotification(notification)
            }
            
            scheduledNotifications.append(contentsOf: newNotifications)
            isSchedulingNotifications = false
            
        } catch {
            isSchedulingNotifications = false
            let notificationError = error as? NotificationError ?? .unknown(error)
            lastError = notificationError
            throw notificationError
        }
    }
    
    func scheduleWeeklyNotifications(for weeklyPrayerTimes: [DailyPrayerTimes]) async throws {
        guard authorizationStatus == .authorized else {
            throw NotificationError.permissionDenied
        }
        
        isSchedulingNotifications = true
        
        do {
            // Clear all existing notifications
            await clearAllNotifications()
            
            var allNotifications: [PrayerNotification] = []
            
            for dailyPrayerTimes in weeklyPrayerTimes {
                for prayer in dailyPrayerTimes.prayers {
                    guard prayer.name.isObligatoryPrayer else { continue }
                    
                    let notificationsForPrayer = try await createNotifications(for: prayer)
                    allNotifications.append(contentsOf: notificationsForPrayer)
                }
            }
            
            // Schedule all notifications (limited by iOS to 64 pending notifications)
            let limitedNotifications = Array(allNotifications.prefix(60)) // Leave some buffer
            
            for notification in limitedNotifications {
                try await scheduleNotification(notification)
            }
            
            scheduledNotifications = limitedNotifications
            isSchedulingNotifications = false
            
        } catch {
            isSchedulingNotifications = false
            let notificationError = error as? NotificationError ?? .unknown(error)
            lastError = notificationError
            throw notificationError
        }
    }
    
    func cancelNotification(_ notification: PrayerNotification) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notification.id])
        scheduledNotifications.removeAll { $0.id == notification.id }
    }
    
    func cancelAllNotifications() async {
        await clearAllNotifications()
    }
    
    func updateNotificationSettings(_ settings: NotificationSettings) {
        notificationSettings = settings
        preferences.saveSettings(settings)
        
        // Reschedule notifications if needed
        Task {
            await rescheduleNotificationsIfNeeded()
        }
    }
    
    func getScheduledNotificationCount() async -> Int {
        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        return pendingRequests.count
    }
    
    // MARK: - Private Methods
    
    private func checkAuthorizationStatus() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            await MainActor.run {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    private func loadNotificationSettings() {
        notificationSettings = preferences.loadSettings()
    }
    
    private func createNotifications(for prayer: PrayerTime) async throws -> [PrayerNotification] {
        var notifications: [PrayerNotification] = []
        
        // Check which notification types are enabled for this prayer
        let enabledTypes = getEnabledNotificationTypes(for: prayer.name)
        
        for type in enabledTypes {
            let scheduledTime = prayer.adjustedTime.addingTimeInterval(TimeInterval(type.offsetMinutes * 60))
            
            // Only schedule future notifications
            guard scheduledTime > Date() else { continue }
            
            let notification = PrayerNotification(
                prayer: prayer.name,
                scheduledTime: scheduledTime,
                type: type,
                isActive: true
            )
            
            notifications.append(notification)
        }
        
        return notifications
    }
    
    private func scheduleNotification(_ notification: PrayerNotification) async throws {
        let content = UNMutableNotificationContent()
        
        // Configure notification content
        configureNotificationContent(content, for: notification)
        
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notification.scheduledTime),
            repeats: false
        )
        
        // Create request
        let request = UNNotificationRequest(
            identifier: notification.id,
            content: content,
            trigger: trigger
        )
        
        try await notificationCenter.add(request)
    }
    
    private func configureNotificationContent(_ content: UNMutableNotificationContent, for notification: PrayerNotification) {
        let prayer = notification.prayer
        let type = notification.notificationType
        
        switch type {
        case .call:
            content.title = "\(prayer.displayName) Time"
            content.body = "It's time for \(prayer.displayName) prayer"
            content.sound = getNotificationSound(for: prayer, type: type)
            
        case .reminder5, .reminder15, .reminder30:
            content.title = "\(prayer.displayName) Prayer Reminder"
            content.body = "\(prayer.displayName) prayer is in \(abs(type.offsetMinutes)) minutes"
            content.sound = getNotificationSound(for: prayer, type: type)
        }
        
        // Add category for interactive notifications
        content.categoryIdentifier = "PRAYER_NOTIFICATION"
        
        // Add user info for handling
        content.userInfo = [
            "prayer": prayer.rawValue,
            "type": type.rawValue,
            "scheduledTime": notification.scheduledTime.timeIntervalSince1970
        ]
        
        // Add badge count
        content.badge = 1
    }
    
    private func getNotificationSound(for prayer: PrayerName, type: PrayerNotificationType) -> UNNotificationSound? {
        let soundPreference = preferences.getSound(for: prayer, type: type)
        
        if let soundName = soundPreference.soundName {
            return UNNotificationSound(named: soundName)
        } else {
            return nil // Silent
        }
    }
    
    private func getEnabledNotificationTypes(for prayer: PrayerName) -> [PrayerNotificationType] {
        return PrayerNotificationType.allCases.filter { type in
            notificationSettings.isEnabled(for: prayer, type: type)
        }
    }
    
    private func clearNotifications(for date: Date) async {
        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        let calendar = Calendar.current
        
        let identifiersToRemove = pendingRequests.compactMap { request -> String? in
            guard let trigger = request.trigger as? UNCalendarNotificationTrigger,
                  let triggerDate = calendar.date(from: trigger.dateComponents) else {
                return nil
            }
            
            if calendar.isDate(triggerDate, inSameDayAs: date) {
                return request.identifier
            }
            
            return nil
        }
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        
        // Update local array
        scheduledNotifications.removeAll { notification in
            calendar.isDate(notification.scheduledTime, inSameDayAs: date)
        }
    }
    
    private func clearAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        scheduledNotifications.removeAll()
    }
    
    private func rescheduleNotificationsIfNeeded() async {
        // This would typically fetch current prayer times and reschedule
        // For now, just clear and let the main app reschedule
        await clearAllNotifications()
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension PrayerNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        handleNotificationResponse(response)
        completionHandler()
    }
    
    private func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        
        guard let prayerRawValue = userInfo["prayer"] as? String,
              let prayer = PrayerName(rawValue: prayerRawValue),
              let typeRawValue = userInfo["type"] as? String,
              let type = PrayerNotificationType(rawValue: typeRawValue) else {
            return
        }
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification
            handleDefaultAction(prayer: prayer, type: type)
            
        case "PLAY_ADHAN":
            // User chose to play adhan
            handlePlayAdhanAction(prayer: prayer)
            
        case "SNOOZE":
            // User chose to snooze
            handleSnoozeAction(prayer: prayer, type: type)
            
        case UNNotificationDismissActionIdentifier:
            // User dismissed the notification
            break
            
        default:
            break
        }
    }
    
    private func handleDefaultAction(prayer: PrayerName, type: PrayerNotificationType) {
        if type == .call {
            // Play adhan automatically for prayer time notifications
            Task {
                await AdhanAudioManager.shared.playAdhan(for: prayer)
            }
        }
        
        // Navigate to prayer times view
        NotificationCenter.default.post(name: .showPrayerTimes, object: prayer)
    }
    
    private func handlePlayAdhanAction(prayer: PrayerName) {
        Task {
            await AdhanAudioManager.shared.playAdhan(for: prayer)
        }
    }
    
    private func handleSnoozeAction(prayer: PrayerName, type: PrayerNotificationType) {
        // Schedule a snooze notification (5 minutes later)
        let snoozeTime = Date().addingTimeInterval(5 * 60)
        let snoozeNotification = PrayerNotification(
            prayer: prayer,
            scheduledTime: snoozeTime,
            type: type
        )
        
        Task {
            try? await scheduleNotification(snoozeNotification)
        }
    }
}

// MARK: - Notification Settings
struct NotificationSettings {
    var isGloballyEnabled: Bool = true
    var prayerSettings: [PrayerName: PrayerNotificationSettings] = [:]
    var doNotDisturbEnabled: Bool = false
    var doNotDisturbStart: Date = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
    var doNotDisturbEnd: Date = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date()) ?? Date()
    
    init() {
        // Initialize with default settings for all prayers
        for prayer in PrayerName.allCases where prayer.isObligatoryPrayer {
            prayerSettings[prayer] = PrayerNotificationSettings()
        }
    }
    
    func isEnabled(for prayer: PrayerName, type: PrayerNotificationType) -> Bool {
        guard isGloballyEnabled else { return false }
        
        if doNotDisturbEnabled && isInDoNotDisturbPeriod() {
            return false
        }
        
        return prayerSettings[prayer]?.isEnabled(for: type) ?? false
    }
    
    private func isInDoNotDisturbPeriod() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        
        let nowTime = calendar.dateComponents([.hour, .minute], from: now)
        let startTime = calendar.dateComponents([.hour, .minute], from: doNotDisturbStart)
        let endTime = calendar.dateComponents([.hour, .minute], from: doNotDisturbEnd)
        
        // Handle overnight period (e.g., 22:00 to 06:00)
        if let startHour = startTime.hour, let startMinute = startTime.minute,
           let endHour = endTime.hour, let endMinute = endTime.minute,
           let nowHour = nowTime.hour, let nowMinute = nowTime.minute {
            
            let startMinutes = startHour * 60 + startMinute
            let endMinutes = endHour * 60 + endMinute
            let nowMinutes = nowHour * 60 + nowMinute
            
            if startMinutes > endMinutes {
                // Overnight period
                return nowMinutes >= startMinutes || nowMinutes <= endMinutes
            } else {
                // Same day period
                return nowMinutes >= startMinutes && nowMinutes <= endMinutes
            }
        }
        
        return false
    }
}

struct PrayerNotificationSettings {
    var callEnabled: Bool = true
    var reminder5Enabled: Bool = false
    var reminder15Enabled: Bool = false
    var reminder30Enabled: Bool = false
    var soundPreference: NotificationSound = .adhan
    var vibrationEnabled: Bool = true
    
    func isEnabled(for type: PrayerNotificationType) -> Bool {
        switch type {
        case .call:
            return callEnabled
        case .reminder5:
            return reminder5Enabled
        case .reminder15:
            return reminder15Enabled
        case .reminder30:
            return reminder30Enabled
        }
    }
    
    mutating func setEnabled(_ enabled: Bool, for type: PrayerNotificationType) {
        switch type {
        case .call:
            callEnabled = enabled
        case .reminder5:
            reminder5Enabled = enabled
        case .reminder15:
            reminder15Enabled = enabled
        case .reminder30:
            reminder30Enabled = enabled
        }
    }
}

// MARK: - Notification Preferences Manager
class NotificationPreferences {
    static let shared = NotificationPreferences()
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "NotificationSettings"
    private let soundPrefix = "NotificationSound_"
    
    private init() {}
    
    func saveSettings(_ settings: NotificationSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            userDefaults.set(data, forKey: settingsKey)
        }
    }
    
    func loadSettings() -> NotificationSettings {
        guard let data = userDefaults.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data) else {
            return NotificationSettings()
        }
        return settings
    }
    
    func getSound(for prayer: PrayerName, type: PrayerNotificationType) -> NotificationSound {
        let key = soundPrefix + prayer.rawValue + "_" + type.rawValue
        let rawValue = userDefaults.string(forKey: key) ?? NotificationSound.adhan.rawValue
        return NotificationSound(rawValue: rawValue) ?? .adhan
    }
    
    func setSound(_ sound: NotificationSound, for prayer: PrayerName, type: PrayerNotificationType) {
        let key = soundPrefix + prayer.rawValue + "_" + type.rawValue
        userDefaults.set(sound.rawValue, forKey: key)
    }
}

// MARK: - Notification Errors
enum NotificationError: LocalizedError {
    case permissionDenied
    case schedulingFailed
    case invalidConfiguration
    case systemLimitReached
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Notification permission denied. Please enable notifications in Settings."
        case .schedulingFailed:
            return "Failed to schedule prayer notifications."
        case .invalidConfiguration:
            return "Invalid notification configuration."
        case .systemLimitReached:
            return "System notification limit reached. Some notifications may not be scheduled."
        case .unknown(let error):
            return "Notification error: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "Go to Settings > Notifications and enable notifications for this app."
        case .schedulingFailed:
            return "Please try again or restart the app."
        case .invalidConfiguration:
            return "Check your notification settings and try again."
        case .systemLimitReached:
            return "Clear some existing notifications or disable some reminder types."
        case .unknown:
            return "Please try again. If the problem persists, restart the app."
        }
    }
}

// MARK: - Notification Categories and Actions
extension PrayerNotificationManager {
    func setupNotificationCategories() {
        let playAdhanAction = UNNotificationAction(
            identifier: "PLAY_ADHAN",
            title: "Play Adhan",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Snooze",
            options: []
        )
        
        let prayerCategory = UNNotificationCategory(
            identifier: "PRAYER_NOTIFICATION",
            actions: [playAdhanAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        notificationCenter.setNotificationCategories([prayerCategory])
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let showPrayerTimes = Notification.Name("showPrayerTimes")
    static let playAdhan = Notification.Name("playAdhan")
}

// Make NotificationSettings and PrayerNotificationSettings Codable
extension NotificationSettings: Codable {
    enum CodingKeys: String, CodingKey {
        case isGloballyEnabled
        case prayerSettings
        case doNotDisturbEnabled
        case doNotDisturbStart
        case doNotDisturbEnd
    }
}

extension PrayerNotificationSettings: Codable {}