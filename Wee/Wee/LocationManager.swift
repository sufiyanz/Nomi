import Foundation
import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var currentPrayerLocation: PrayerLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    @Published var lastError: LocationError?
    @Published var lastUpdateDate: Date?
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var cancellables = Set<AnyCancellable>()
    
    // Configuration
    private let desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters
    private let distanceFilter: CLLocationDistance = 500.0 // 500 meters
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Public Methods
    
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Show settings alert
            showLocationSettingsAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func getCurrentLocation() async throws -> PrayerLocation {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            throw LocationError.permissionDenied
        }
        
        isLoading = true
        lastError = nil
        
        do {
            let location = try await requestOneTimeLocation()
            let prayerLocation = try await convertToPrayerLocation(location)
            
            currentLocation = location
            currentPrayerLocation = prayerLocation
            lastUpdateDate = Date()
            isLoading = false
            
            return prayerLocation
            
        } catch {
            isLoading = false
            let locationError = error as? LocationError ?? .unknown(error)
            lastError = locationError
            throw locationError
        }
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            lastError = .permissionDenied
            return
        }
        
        guard CLLocationManager.locationServicesEnabled() else {
            lastError = .locationServicesDisabled
            return
        }
        
        isLoading = true
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLoading = false
    }
    
    func getStoredLocation() -> PrayerLocation? {
        return LocationPreferences.shared.savedLocation
    }
    
    func saveLocation(_ location: PrayerLocation) {
        LocationPreferences.shared.saveLocation(location)
        currentPrayerLocation = location
    }
    
    func clearStoredLocation() {
        LocationPreferences.shared.clearLocation()
        currentPrayerLocation = nil
    }
    
    // MARK: - Private Methods
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = desiredAccuracy
        locationManager.distanceFilter = distanceFilter
        
        authorizationStatus = locationManager.authorizationStatus
    }
    
    private func requestOneTimeLocation() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { continuation in
            var resumed = false
            
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: 15_000_000_000) // 15 seconds timeout
                if !resumed {
                    resumed = true
                    continuation.resume(throwing: LocationError.timeout)
                    stopLocationUpdates()
                }
            }
            
            // Start location updates and wait for first result
            let subscription = $currentLocation
                .compactMap { $0 }
                .first()
                .sink { location in
                    if !resumed {
                        resumed = true
                        timeoutTask.cancel()
                        continuation.resume(returning: location)
                        self.stopLocationUpdates()
                    }
                }
            
            startLocationUpdates()
            
            // Store subscription to prevent deallocation
            cancellables.insert(subscription)
        }
    }
    
    private func convertToPrayerLocation(_ location: CLLocation) async throws -> PrayerLocation {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            
            guard let placemark = placemarks.first else {
                return PrayerLocation(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
            
            return PrayerLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                city: placemark.locality,
                country: placemark.country,
                timezone: placemark.timeZone?.identifier
            )
            
        } catch {
            // If geocoding fails, return basic location
            return PrayerLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        }
    }
    
    private func showLocationSettingsAlert() {
        lastError = .permissionDenied
        // In a real app, this would show an alert directing users to Settings
        // For now, we'll just set the error state
    }
    
    private func handleLocationError(_ error: Error) {
        let locationError: LocationError
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationError = .permissionDenied
            case .locationUnknown:
                locationError = .locationUnavailable
            case .network:
                locationError = .networkUnavailable
            case .headingFailure:
                locationError = .headingUnavailable
            case .rangingUnavailable, .rangingFailure:
                locationError = .rangingUnavailable
            case .promptDeclined:
                locationError = .permissionDenied
            default:
                locationError = .unknown(error)
            }
        } else {
            locationError = .unknown(error)
        }
        
        lastError = locationError
        isLoading = false
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Filter out old or inaccurate readings
        let age = abs(location.timestamp.timeIntervalSinceNow)
        guard age < 5.0 && location.horizontalAccuracy < 100 else { return }
        
        currentLocation = location
        
        // Convert to prayer location asynchronously
        Task {
            do {
                let prayerLocation = try await convertToPrayerLocation(location)
                await MainActor.run {
                    self.currentPrayerLocation = prayerLocation
                    self.lastUpdateDate = Date()
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.handleLocationError(error)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleLocationError(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                startLocationUpdates()
            }
        case .denied, .restricted:
            lastError = .permissionDenied
            stopLocationUpdates()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

// MARK: - Location Preferences Manager
class LocationPreferences {
    static let shared = LocationPreferences()
    
    private let userDefaults = UserDefaults.standard
    private let locationKey = "SavedPrayerLocation"
    private let autoLocationKey = "AutoLocationEnabled"
    private let locationAccuracyKey = "LocationAccuracy"
    
    private init() {}
    
    var savedLocation: PrayerLocation? {
        get {
            guard let data = userDefaults.data(forKey: locationKey),
                  let location = try? JSONDecoder().decode(PrayerLocation.self, from: data) else {
                return nil
            }
            return location
        }
    }
    
    var isAutoLocationEnabled: Bool {
        get {
            userDefaults.bool(forKey: autoLocationKey)
        }
        set {
            userDefaults.set(newValue, forKey: autoLocationKey)
        }
    }
    
    var locationAccuracy: LocationAccuracy {
        get {
            let rawValue = userDefaults.string(forKey: locationAccuracyKey) ?? LocationAccuracy.balanced.rawValue
            return LocationAccuracy(rawValue: rawValue) ?? .balanced
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: locationAccuracyKey)
        }
    }
    
    func saveLocation(_ location: PrayerLocation) {
        if let data = try? JSONEncoder().encode(location) {
            userDefaults.set(data, forKey: locationKey)
        }
    }
    
    func clearLocation() {
        userDefaults.removeObject(forKey: locationKey)
    }
}

// MARK: - Location Accuracy Options
enum LocationAccuracy: String, CaseIterable {
    case high = "high"
    case balanced = "balanced"
    case low = "low"
    
    var displayName: String {
        switch self {
        case .high:
            return "High Accuracy"
        case .balanced:
            return "Balanced"
        case .low:
            return "Low Power"
        }
    }
    
    var description: String {
        switch self {
        case .high:
            return "Most accurate, higher battery usage"
        case .balanced:
            return "Good accuracy, moderate battery usage"
        case .low:
            return "Approximate location, lowest battery usage"
        }
    }
    
    var clLocationAccuracy: CLLocationAccuracy {
        switch self {
        case .high:
            return kCLLocationAccuracyBest
        case .balanced:
            return kCLLocationAccuracyHundredMeters
        case .low:
            return kCLLocationAccuracyKilometer
        }
    }
}

// MARK: - Location Errors
enum LocationError: LocalizedError {
    case permissionDenied
    case locationServicesDisabled
    case locationUnavailable
    case networkUnavailable
    case timeout
    case geocodingFailed
    case headingUnavailable
    case rangingUnavailable
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied. Please enable location access in Settings."
        case .locationServicesDisabled:
            return "Location services are disabled. Please enable them in Settings."
        case .locationUnavailable:
            return "Current location is unavailable. Please try again."
        case .networkUnavailable:
            return "Network connection required for location services."
        case .timeout:
            return "Location request timed out. Please try again."
        case .geocodingFailed:
            return "Failed to get location details. Using coordinates only."
        case .headingUnavailable:
            return "Device heading is unavailable."
        case .rangingUnavailable:
            return "Location ranging is unavailable."
        case .unknown(let error):
            return "Location error: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "Go to Settings > Privacy & Security > Location Services and enable location access for this app."
        case .locationServicesDisabled:
            return "Go to Settings > Privacy & Security > Location Services and turn on Location Services."
        case .locationUnavailable:
            return "Make sure you're in an area with good GPS reception and try again."
        case .networkUnavailable:
            return "Check your internet connection and try again."
        case .timeout:
            return "Move to an open area with better GPS reception."
        case .geocodingFailed:
            return "Check your internet connection. Location coordinates will still work."
        case .headingUnavailable, .rangingUnavailable:
            return "This feature requires a newer device with appropriate sensors."
        case .unknown:
            return "Please try again. If the problem persists, restart the app."
        }
    }
}

// MARK: - Location Validation
struct LocationValidator {
    static func isValidCoordinate(latitude: Double, longitude: Double) -> Bool {
        return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180
    }
    
    static func isValidLocation(_ location: PrayerLocation) -> Bool {
        return isValidCoordinate(latitude: location.latitude, longitude: location.longitude)
    }
    
    static func distanceBetween(_ location1: PrayerLocation, _ location2: PrayerLocation) -> CLLocationDistance {
        let loc1 = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let loc2 = CLLocation(latitude: location2.latitude, longitude: location2.longitude)
        return loc1.distance(from: loc2)
    }
    
    static func shouldUpdateLocation(current: PrayerLocation?, new: PrayerLocation, threshold: CLLocationDistance = 1000) -> Bool {
        guard let current = current else { return true }
        return distanceBetween(current, new) > threshold
    }
}

// MARK: - Manual Location Entry
struct ManualLocationEntry {
    let searchText: String
    let coordinates: (latitude: Double, longitude: Double)?
    let city: String?
    let country: String?
    
    func toPrayerLocation() -> PrayerLocation? {
        guard let coordinates = coordinates else { return nil }
        
        return PrayerLocation(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude,
            city: city,
            country: country
        )
    }
}

class LocationSearchManager: ObservableObject {
    @Published var searchResults: [CLPlacemark] = []
    @Published var isSearching = false
    @Published var searchError: LocationError?
    
    private let geocoder = CLGeocoder()
    
    func searchLocation(_ query: String) async {
        guard !query.isEmpty else { return }
        
        await MainActor.run {
            isSearching = true
            searchError = nil
        }
        
        do {
            let placemarks = try await geocoder.geocodeAddressString(query)
            
            await MainActor.run {
                self.searchResults = placemarks
                self.isSearching = false
            }
            
        } catch {
            await MainActor.run {
                self.searchError = .geocodingFailed
                self.isSearching = false
            }
        }
    }
    
    func convertToLocation(_ placemark: CLPlacemark) -> PrayerLocation? {
        guard let coordinate = placemark.location?.coordinate else { return nil }
        
        return PrayerLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            city: placemark.locality,
            country: placemark.country,
            timezone: placemark.timeZone?.identifier
        )
    }
}