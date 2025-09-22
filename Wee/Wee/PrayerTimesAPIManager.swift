import Foundation
import Combine

// MARK: - Aladhan API Response Models
struct AladhanResponse: Codable {
    let code: Int
    let status: String
    let data: AladhanData
}

struct AladhanData: Codable {
    let timings: AladhanTimings
    let date: AladhanDate
    let meta: AladhanMeta
}

struct AladhanTimings: Codable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Sunset: String
    let Maghrib: String
    let Isha: String
    let Imsak: String?
    let Midnight: String?
    let Firstthird: String?
    let Lastthird: String?
}

struct AladhanDate: Codable {
    let readable: String
    let timestamp: String
    let hijri: AladhanHijriDate
    let gregorian: AladhanGregorianDate
}

struct AladhanHijriDate: Codable {
    let date: String
    let format: String
    let day: String
    let weekday: AladhanWeekday
    let month: AladhanMonth
    let year: String
    let designation: AladhanDesignation
    let holidays: [String]?
}

struct AladhanGregorianDate: Codable {
    let date: String
    let format: String
    let day: String
    let weekday: AladhanWeekday
    let month: AladhanMonth
    let year: String
    let designation: AladhanDesignation
}

struct AladhanWeekday: Codable {
    let en: String
    let ar: String?
}

struct AladhanMonth: Codable {
    let number: Int
    let en: String
    let ar: String?
}

struct AladhanDesignation: Codable {
    let abbreviated: String
    let expanded: String
}

struct AladhanMeta: Codable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let method: AladhanMethod
    let latitudeAdjustmentMethod: String
    let midnightMode: String
    let school: String
    let offset: [String: Int]?
}

struct AladhanMethod: Codable {
    let id: Int
    let name: String
    let params: [String: AnyHashable]?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, params
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        // Handle params as a flexible dictionary
        if let paramsContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .params) {
            params = [:]
        } else {
            params = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        // Skip encoding params for now since it's not essential
    }
}

// MARK: - Prayer Times API Manager
@MainActor
class PrayerTimesAPIManager: ObservableObject {
    static let shared = PrayerTimesAPIManager()
    
    @Published var isLoading = false
    @Published var lastError: PrayerTimesError?
    @Published var lastUpdateDate: Date?
    
    private let baseURL = "https://api.aladhan.com/v1"
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchPrayerTimes(
        for location: PrayerLocation,
        date: Date = Date(),
        calculationMethod: CalculationMethod = .default
    ) async throws -> DailyPrayerTimes {
        isLoading = true
        lastError = nil
        
        do {
            let response = try await performAPIRequest(
                location: location,
                date: date,
                calculationMethod: calculationMethod
            )
            
            let prayerTimes = try convertToPrayerTimes(
                from: response,
                location: location,
                date: date,
                calculationMethod: calculationMethod
            )
            
            lastUpdateDate = Date()
            isLoading = false
            
            return prayerTimes
            
        } catch {
            isLoading = false
            let prayerError = error as? PrayerTimesError ?? .unknown(error)
            lastError = prayerError
            throw prayerError
        }
    }
    
    func fetchPrayerTimes(
        for coordinates: (latitude: Double, longitude: Double),
        date: Date = Date(),
        calculationMethod: CalculationMethod = .default
    ) async throws -> DailyPrayerTimes {
        let location = PrayerLocation(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude
        )
        
        return try await fetchPrayerTimes(
            for: location,
            date: date,
            calculationMethod: calculationMethod
        )
    }
    
    func fetchMonthlyPrayerTimes(
        for location: PrayerLocation,
        month: Int,
        year: Int,
        calculationMethod: CalculationMethod = .default
    ) async throws -> [DailyPrayerTimes] {
        isLoading = true
        lastError = nil
        
        do {
            let urlString = "\(baseURL)/calendar/\(year)/\(month)"
            let queryItems = buildQueryItems(for: location, calculationMethod: calculationMethod)
            
            guard var components = URLComponents(string: urlString) else {
                throw PrayerTimesError.invalidURL
            }
            components.queryItems = queryItems
            
            guard let url = components.url else {
                throw PrayerTimesError.invalidURL
            }
            
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw PrayerTimesError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw PrayerTimesError.serverError(httpResponse.statusCode)
            }
            
            let monthlyResponse = try JSONDecoder().decode(AladhanMonthlyResponse.self, from: data)
            
            if monthlyResponse.code != 200 {
                throw PrayerTimesError.apiError(monthlyResponse.status)
            }
            
            let monthlyPrayerTimes = try monthlyResponse.data.compactMap { dailyData in
                try convertToPrayerTimes(
                    from: AladhanResponse(code: 200, status: "OK", data: dailyData),
                    location: location,
                    date: parseDate(from: dailyData.date.readable),
                    calculationMethod: calculationMethod
                )
            }
            
            lastUpdateDate = Date()
            isLoading = false
            
            return monthlyPrayerTimes
            
        } catch {
            isLoading = false
            let prayerError = error as? PrayerTimesError ?? .unknown(error)
            lastError = prayerError
            throw prayerError
        }
    }
    
    // MARK: - Private Methods
    
    private func performAPIRequest(
        location: PrayerLocation,
        date: Date,
        calculationMethod: CalculationMethod
    ) async throws -> AladhanResponse {
        let dateString = formatDateForAPI(date)
        let urlString = "\(baseURL)/timings/\(dateString)"
        
        let queryItems = buildQueryItems(for: location, calculationMethod: calculationMethod)
        
        guard var components = URLComponents(string: urlString) else {
            throw PrayerTimesError.invalidURL
        }
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw PrayerTimesError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PrayerTimesError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw PrayerTimesError.serverError(httpResponse.statusCode)
        }
        
        let aladhanResponse = try JSONDecoder().decode(AladhanResponse.self, from: data)
        
        if aladhanResponse.code != 200 {
            throw PrayerTimesError.apiError(aladhanResponse.status)
        }
        
        return aladhanResponse
    }
    
    private func buildQueryItems(
        for location: PrayerLocation,
        calculationMethod: CalculationMethod
    ) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            URLQueryItem(name: "method", value: calculationMethod.rawValue)
        ]
        
        if let timezone = location.timezone {
            queryItems.append(URLQueryItem(name: "timezonestring", value: timezone))
        }
        
        return queryItems
    }
    
    private func convertToPrayerTimes(
        from response: AladhanResponse,
        location: PrayerLocation,
        date: Date,
        calculationMethod: CalculationMethod
    ) throws -> DailyPrayerTimes {
        let timings = response.data.timings
        let timeZone = TimeZone(identifier: response.data.meta.timezone) ?? TimeZone.current
        
        let prayerTimes: [PrayerTime] = [
            try createPrayerTime(.fajr, from: timings.Fajr, date: date, timeZone: timeZone),
            try createPrayerTime(.sunrise, from: timings.Sunrise, date: date, timeZone: timeZone),
            try createPrayerTime(.dhuhr, from: timings.Dhuhr, date: date, timeZone: timeZone),
            try createPrayerTime(.asr, from: timings.Asr, date: date, timeZone: timeZone),
            try createPrayerTime(.maghrib, from: timings.Maghrib, date: date, timeZone: timeZone),
            try createPrayerTime(.isha, from: timings.Isha, date: date, timeZone: timeZone)
        ]
        
        return DailyPrayerTimes(
            date: date,
            prayers: prayerTimes,
            location: location,
            calculationMethod: calculationMethod
        )
    }
    
    private func createPrayerTime(
        _ name: PrayerName,
        from timeString: String,
        date: Date,
        timeZone: TimeZone
    ) throws -> PrayerTime {
        guard let time = parseTime(timeString, for: date, in: timeZone) else {
            throw PrayerTimesError.invalidTimeFormat(timeString)
        }
        
        return PrayerTime(name: name, time: time, date: date)
    }
    
    private func parseTime(_ timeString: String, for date: Date, in timeZone: TimeZone) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = timeZone
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let parsedTime = formatter.date(from: timeString) else {
            return nil
        }
        
        let timeComponents = calendar.dateComponents([.hour, .minute], from: parsedTime)
        
        var finalComponents = dateComponents
        finalComponents.hour = timeComponents.hour
        finalComponents.minute = timeComponents.minute
        finalComponents.timeZone = timeZone
        
        return calendar.date(from: finalComponents)
    }
    
    private func formatDateForAPI(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
    
    private func parseDate(from dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.date(from: dateString) ?? Date()
    }
}

// MARK: - Monthly Response Model
struct AladhanMonthlyResponse: Codable {
    let code: Int
    let status: String
    let data: [AladhanData]
}

// MARK: - Prayer Times Errors
enum PrayerTimesError: LocalizedError {
    case networkUnavailable
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case apiError(String)
    case invalidTimeFormat(String)
    case locationUnavailable
    case permissionDenied
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network connection is unavailable. Please check your internet connection."
        case .invalidURL:
            return "Invalid API URL. Please try again."
        case .invalidResponse:
            return "Invalid response from prayer times service."
        case .serverError(let code):
            return "Server error (Code: \(code)). Please try again later."
        case .apiError(let message):
            return "API Error: \(message)"
        case .invalidTimeFormat(let timeString):
            return "Invalid time format received: \(timeString)"
        case .locationUnavailable:
            return "Location information is unavailable. Please enable location services."
        case .permissionDenied:
            return "Location permission denied. Please enable location access in Settings."
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Check your internet connection and try again."
        case .invalidURL, .invalidResponse:
            return "Please try again. If the problem persists, contact support."
        case .serverError:
            return "The prayer times service is temporarily unavailable. Please try again later."
        case .apiError:
            return "Please try again with different settings."
        case .invalidTimeFormat:
            return "Please try again or use a different calculation method."
        case .locationUnavailable, .permissionDenied:
            return "Enable location services in Settings > Privacy & Security > Location Services."
        case .unknown:
            return "Please try again. If the problem persists, restart the app."
        }
    }
}