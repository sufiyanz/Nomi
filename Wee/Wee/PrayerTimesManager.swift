import Foundation
import SwiftData
import Combine
import CoreLocation
import UIKit

// MARK: - Main Prayer Times Manager
@MainActor
class PrayerTimesManager: ObservableObject {
    static let shared = PrayerTimesManager()
    
    // Published properties for UI binding
    @Published var currentPrayerTimes: DailyPrayerTimes?
    @Published var nextPrayer: PrayerTime?
    @Published var currentPrayer: PrayerTime?
    @Published var isLoading = false
    @Published var lastError: PrayerTimesError?
    @Published var lastUpdateDate: Date?
    
    // Computed property for dashboard compatibility
    var todayPrayerTimes: DailyPrayerTimes? {
        return currentPrayerTimes
    }
    
    // Sub-managers
    private let apiManager = PrayerTimesAPIManager.shared
    private let locationManager = LocationManager.shared
    private let notificationManager = PrayerNotificationManager.shared
    private let audioManager = AdhanAudioManager.shared
    
    // Configuration
    @Published var calculationMethod: CalculationMethod = .worldIslamicLeague
    @Published var autoUpdateEnabled = true
    @Published var updateInterval: TimeInterval = 3600 // 1 hour
    
    // Internal state
    private var updateTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let preferences = PrayerTimesPreferences.shared
    
    private init() {
        loadPreferences()
        setupObservers()
        setupUpdateTimer()
    }
    
    // MARK: - Public Methods
    
    func initialize() async {
        do {
            // Request permissions
            try await requestPermissions()
            
            // Load current prayer times
            await loadTodayPrayerTimes()
            
            // Schedule notifications
            if let prayerTimes = currentPrayerTimes {
                try await notificationManager.scheduleNotifications(for: prayerTimes)
            }
            
        } catch {
            lastError = error as? PrayerTimesError ?? .unknown(error)
        }
    }
    
    func refreshPrayerTimes() async {
        await loadTodayPrayerTimes()
    }
    
    func loadTodayPrayerTimes() async {
        guard !isLoading else { 
            return 
        }
        
        isLoading = true
        lastError = nil
        
        do {
            print("📍 Getting current location...")
            let location = try await getCurrentLocation()
            print("📍 Got location: \(location.latitude), \(location.longitude)")
            
            print("📍 Fetching prayer times from API...")
            let prayerTimes = try await apiManager.fetchPrayerTimes(
                for: location,
                date: Date(),
                calculationMethod: calculationMethod
            )
            print("📍 Successfully fetched prayer times: \(prayerTimes.prayers.count) prayers")
            
            currentPrayerTimes = prayerTimes
            updateCurrentAndNextPrayer()
            savePreferences()
            lastUpdateDate = Date()
            
            // Schedule notifications for today
            try await notificationManager.scheduleNotifications(for: prayerTimes)
            
            isLoading = false
            print("📍 Prayer times loaded successfully!")
            
        } catch {
            isLoading = false
            let prayerError = error as? PrayerTimesError ?? .unknown(error)
            lastError = prayerError
            print("❌ Failed to load prayer times: \(error.localizedDescription)")
            
            // Try to load cached data if available
            loadCachedPrayerTimes()
        }
    }
    
    func loadPrayerTimes(for date: Date) async throws -> DailyPrayerTimes {
        let location = try await getCurrentLocation()
        return try await apiManager.fetchPrayerTimes(
            for: location,
            date: date,
            calculationMethod: calculationMethod
        )
    }
    
    func setCalculationMethod(_ method: CalculationMethod) {
        calculationMethod = method
        preferences.calculationMethod = method
        
        // Refresh prayer times with new method
        Task {
            await loadTodayPrayerTimes()
        }
    }
    
    func setAutoUpdate(_ enabled: Bool) {
        autoUpdateEnabled = enabled
        preferences.autoUpdateEnabled = enabled
        
        if enabled {
            setupUpdateTimer()
        } else {
            stopUpdateTimer()
        }
    }
    
    func playAdhan(for prayer: PrayerName) async {
        await audioManager.playAdhan(for: prayer)
    }
    
    func getTimeUntilNextPrayer() -> String {
        guard let nextPrayer = nextPrayer else {
            return "No upcoming prayer"
        }
        
        let timeInterval = nextPrayer.timeUntil
        
        if timeInterval <= 0 {
            return "Prayer time has passed"
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 3600)) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    func getPrayerProgress() -> Double {
        guard let currentPrayerTimes = currentPrayerTimes else { return 0.0 }
        
        let now = Date()
        let prayers = currentPrayerTimes.obligatoryPrayers.sorted { $0.adjustedTime < $1.adjustedTime }
        
        // Find current prayer period
        for (index, prayer) in prayers.enumerated() {
            let nextIndex = (index + 1) % prayers.count
            let nextPrayer = prayers[nextIndex]
            
            var nextPrayerTime = nextPrayer.adjustedTime
            
            // If next prayer is tomorrow (for Isha to Fajr)
            if nextPrayerTime <= prayer.adjustedTime {
                nextPrayerTime = Calendar.current.date(byAdding: .day, value: 1, to: nextPrayerTime) ?? nextPrayerTime
            }
            
            if now >= prayer.adjustedTime && now < nextPrayerTime {
                let totalDuration = nextPrayerTime.timeIntervalSince(prayer.adjustedTime)
                let elapsed = now.timeIntervalSince(prayer.adjustedTime)
                return min(max(elapsed / totalDuration, 0.0), 1.0)
            }
        }
        
        return 0.0
    }
    
    func getCurrentPrayer(for date: Date, prayerTimes: DailyPrayerTimes) -> (name: String, time: Date)? {
        let prayers = prayerTimes.obligatoryPrayers.sorted { $0.adjustedTime < $1.adjustedTime }
        
        // Find the current prayer (the most recent prayer that has passed)
        var currentPrayer: (name: String, time: Date)?
        
        for prayer in prayers {
            if date >= prayer.adjustedTime {
                currentPrayer = (name: prayer.name.rawValue, time: prayer.adjustedTime)
            } else {
                break
            }
        }
        
        // If no prayer has passed today, it means we're before Fajr
        // So the current prayer is Isha from yesterday
        if currentPrayer == nil, let isha = prayers.first(where: { $0.name == .isha }) {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
            let yesterdayIsha = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: isha.adjustedTime),
                                                      minute: Calendar.current.component(.minute, from: isha.adjustedTime),
                                                      second: 0,
                                                      of: yesterday) ?? isha.adjustedTime
            currentPrayer = (name: isha.name.rawValue, time: yesterdayIsha)
        }
        
        return currentPrayer
    }
    
    func getNextPrayer(for date: Date, prayerTimes: DailyPrayerTimes) -> (name: String, time: Date)? {
        let prayers = prayerTimes.obligatoryPrayers.sorted { $0.adjustedTime < $1.adjustedTime }
        
        // Find the next prayer (the first prayer that hasn't passed yet)
        for prayer in prayers {
            if date < prayer.adjustedTime {
                return (name: prayer.name.rawValue, time: prayer.adjustedTime)
            }
        }
        
        // If we're past all prayers today, next prayer is Fajr tomorrow
        if let fajr = prayers.first(where: { $0.name == .fajr }) {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
            let tomorrowFajr = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: fajr.adjustedTime),
                                                     minute: Calendar.current.component(.minute, from: fajr.adjustedTime),
                                                     second: 0,
                                                     of: tomorrow) ?? fajr.adjustedTime
            return (name: fajr.name.rawValue, time: tomorrowFajr)
        }
        
        return nil
    }
    
    // MARK: - Private Methods
    
    private func requestPermissions() async throws {
        // Request location permission
        locationManager.requestLocationPermission()
        
        // Request notification permission
        try await notificationManager.requestNotificationPermission()
    }
    
    private func getCurrentLocation() async throws -> PrayerLocation {
        print("📍 Getting current location...")
        if let savedLocation = locationManager.getStoredLocation() {
            print("📍 Using stored location: \(savedLocation.latitude), \(savedLocation.longitude)")
            return savedLocation
        }
        
        print("📍 Requesting location from LocationManager...")
        return try await locationManager.getCurrentLocation()
    }
    
    private func updateCurrentAndNextPrayer() {
        guard let prayerTimes = currentPrayerTimes else {
            nextPrayer = nil
            currentPrayer = nil
            return
        }
        
        nextPrayer = prayerTimes.nextPrayer
        currentPrayer = prayerTimes.currentPrayer
    }
    
    private func loadPreferences() {
        calculationMethod = preferences.calculationMethod
        autoUpdateEnabled = preferences.autoUpdateEnabled
        updateInterval = preferences.updateInterval
    }
    
    private func savePreferences() {
        preferences.calculationMethod = calculationMethod
        preferences.autoUpdateEnabled = autoUpdateEnabled
        preferences.updateInterval = updateInterval
        preferences.lastUpdateDate = lastUpdateDate
    }
    
    private func setupObservers() {
        // Observe location changes
        locationManager.$currentPrayerLocation
            .compactMap { $0 }
            .removeDuplicates { $0.latitude == $1.latitude && $0.longitude == $1.longitude }
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.loadTodayPrayerTimes()
                }
            }
            .store(in: &cancellables)
        
        // Observe significant time changes (like timezone changes)
        NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.loadTodayPrayerTimes()
                }
            }
            .store(in: &cancellables)
        
        // Update current/next prayer every minute
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCurrentAndNextPrayer()
            }
            .store(in: &cancellables)
    }
    
    private func setupUpdateTimer() {
        guard autoUpdateEnabled else { return }
        
        stopUpdateTimer()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.loadTodayPrayerTimes()
            }
        }
    }
    
    private func stopUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func loadCachedPrayerTimes() {
        if let cachedData = preferences.cachedPrayerTimes,
           let codablePrayerTimes = try? JSONDecoder().decode(CodableDailyPrayerTimes.self, from: cachedData) {
            currentPrayerTimes = codablePrayerTimes.toDailyPrayerTimes()
            updateCurrentAndNextPrayer()
        }
    }
    
    private func cachePrayerTimes(_ prayerTimes: DailyPrayerTimes) {
        let codablePrayerTimes = CodableDailyPrayerTimes(from: prayerTimes)
        if let data = try? JSONEncoder().encode(codablePrayerTimes) {
            preferences.cachedPrayerTimes = data
        }
    }
}

// MARK: - Prayer Times Preferences
class PrayerTimesPreferences {
    static let shared = PrayerTimesPreferences()
    
    private let userDefaults = UserDefaults.standard
    
    // Keys
    private let calculationMethodKey = "CalculationMethod"
    private let autoUpdateKey = "AutoUpdate"
    private let updateIntervalKey = "UpdateInterval"
    private let lastUpdateKey = "LastUpdate"
    private let cachedDataKey = "CachedPrayerTimes"
    
    private init() {}
    
    var calculationMethod: CalculationMethod {
        get {
            let rawValue = userDefaults.string(forKey: calculationMethodKey) ?? CalculationMethod.default.rawValue
            return CalculationMethod(rawValue: rawValue) ?? .default
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: calculationMethodKey)
        }
    }
    
    var autoUpdateEnabled: Bool {
        get {
            userDefaults.bool(forKey: autoUpdateKey)
        }
        set {
            userDefaults.set(newValue, forKey: autoUpdateKey)
        }
    }
    
    var updateInterval: TimeInterval {
        get {
            let interval = userDefaults.double(forKey: updateIntervalKey)
            return interval == 0 ? 3600 : interval // Default 1 hour
        }
        set {
            userDefaults.set(newValue, forKey: updateIntervalKey)
        }
    }
    
    var lastUpdateDate: Date? {
        get {
            let timestamp = userDefaults.double(forKey: lastUpdateKey)
            return timestamp == 0 ? nil : Date(timeIntervalSince1970: timestamp)
        }
        set {
            if let date = newValue {
                userDefaults.set(date.timeIntervalSince1970, forKey: lastUpdateKey)
            } else {
                userDefaults.removeObject(forKey: lastUpdateKey)
            }
        }
    }
    
    var cachedPrayerTimes: Data? {
        get {
            userDefaults.data(forKey: cachedDataKey)
        }
        set {
            userDefaults.set(newValue, forKey: cachedDataKey)
        }
    }
    
    func clearAll() {
        let keys = [calculationMethodKey, autoUpdateKey, updateIntervalKey, lastUpdateKey, cachedDataKey]
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
}

// MARK: - Codable Prayer Time for Caching
struct CodablePrayerTime: Codable {
    let name: PrayerName
    let time: Date
    let adjustmentMinutes: Int
    let isActive: Bool
    let date: Date
    
    init(from prayerTime: PrayerTime) {
        self.name = prayerTime.name
        self.time = prayerTime.time
        self.adjustmentMinutes = prayerTime.adjustmentMinutes
        self.isActive = prayerTime.isActive
        self.date = prayerTime.date
    }
    
    func toPrayerTime() -> PrayerTime {
        return PrayerTime(name: name, time: time, adjustmentMinutes: adjustmentMinutes, isActive: isActive, date: date)
    }
}

struct CodableDailyPrayerTimes: Codable {
    let date: Date
    let prayers: [CodablePrayerTime]
    let location: PrayerLocation
    let calculationMethod: CalculationMethod
    
    init(from dailyPrayerTimes: DailyPrayerTimes) {
        self.date = dailyPrayerTimes.date
        self.prayers = dailyPrayerTimes.prayers.map { CodablePrayerTime(from: $0) }
        self.location = dailyPrayerTimes.location
        self.calculationMethod = dailyPrayerTimes.calculationMethod
    }
    
    func toDailyPrayerTimes() -> DailyPrayerTimes {
        let prayerTimeObjects = prayers.map { $0.toPrayerTime() }
        return DailyPrayerTimes(date: date, prayers: prayerTimeObjects, location: location, calculationMethod: calculationMethod)
    }
}

// MARK: - Prayer Times Status
struct PrayerTimesStatus {
    let isLoaded: Bool
    let lastUpdate: Date?
    let nextUpdate: Date?
    let error: PrayerTimesError?
    let notificationCount: Int
    let locationStatus: String
    
    var statusMessage: String {
        if let error = error {
            return "Error: \(error.localizedDescription)"
        }
        
        if !isLoaded {
            return "Loading prayer times..."
        }
        
        if let lastUpdate = lastUpdate {
            let formatter = RelativeDateTimeFormatter()
            return "Updated \(formatter.localizedString(for: lastUpdate, relativeTo: Date()))"
        }
        
        return "Ready"
    }
}

// MARK: - Debug and Testing Support
extension PrayerTimesManager {
    func getStatus() -> PrayerTimesStatus {
        return PrayerTimesStatus(
            isLoaded: currentPrayerTimes != nil,
            lastUpdate: lastUpdateDate,
            nextUpdate: nil, // Calculate based on update timer
            error: lastError,
            notificationCount: 0, // Get from notification manager
            locationStatus: locationManager.authorizationStatus.localizedDescription
        )
    }
    
    func debugInfo() -> String {
        var info = ["=== Prayer Times Debug Info ==="]
        
        if let prayerTimes = currentPrayerTimes {
            info.append("Date: \(prayerTimes.date)")
            info.append("Location: \(prayerTimes.location.latitude), \(prayerTimes.location.longitude)")
            info.append("Method: \(prayerTimes.calculationMethod.displayName)")
            
            for prayer in prayerTimes.prayers {
                info.append("\(prayer.name.displayName): \(prayer.displayTime)")
            }
        } else {
            info.append("No prayer times loaded")
        }
        
        if let error = lastError {
            info.append("Last Error: \(error.localizedDescription)")
        }
        
        info.append("Auto Update: \(autoUpdateEnabled)")
        info.append("Last Update: \(lastUpdateDate?.description ?? "Never")")
        
        return info.joined(separator: "\n")
    }
}

// MARK: - Utility Extensions
extension CLAuthorizationStatus {
    var localizedDescription: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Always Authorized"
        case .authorizedWhenInUse:
            return "When In Use"
        @unknown default:
            return "Unknown"
        }
    }
}