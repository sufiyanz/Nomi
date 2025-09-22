import Foundation
import SwiftData

@Model
class PrayerTime: Identifiable {
    var id = UUID()
    var name: PrayerName
    var time: Date
    var adjustmentMinutes: Int
    var isActive: Bool
    var date: Date // The date this prayer time is for
    
    init(name: PrayerName, time: Date, adjustmentMinutes: Int = 0, isActive: Bool = true, date: Date = Date()) {
        self.name = name
        self.time = time
        self.adjustmentMinutes = adjustmentMinutes
        self.isActive = isActive
        self.date = date
    }
    
    var adjustedTime: Date {
        return time.addingTimeInterval(TimeInterval(adjustmentMinutes * 60))
    }
    
    var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: adjustedTime)
    }
    
    var timeUntil: TimeInterval {
        return adjustedTime.timeIntervalSinceNow
    }
    
    var isUpcoming: Bool {
        return timeUntil > 0
    }
    
    var isPast: Bool {
        return timeUntil < 0
    }
    
    var isCurrent: Bool {
        let now = Date()
        let prayerTime = adjustedTime
        let nextPrayerOffset: TimeInterval = 1800 // 30 minutes buffer
        
        return now >= prayerTime && now <= prayerTime.addingTimeInterval(nextPrayerOffset)
    }
}

enum PrayerName: String, CaseIterable, Codable {
    case fajr = "Fajr"
    case sunrise = "Sunrise"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"
    
    var displayName: String {
        switch self {
        case .fajr: return "Fajr"
        case .sunrise: return "Sunrise"
        case .dhuhr: return "Dhuhr"
        case .asr: return "Asr"
        case .maghrib: return "Maghrib"
        case .isha: return "Isha"
        }
    }
    
    var arabicName: String {
        switch self {
        case .fajr: return "الفجر"
        case .sunrise: return "الشروق"
        case .dhuhr: return "الظهر"
        case .asr: return "العصر"
        case .maghrib: return "المغرب"
        case .isha: return "العشاء"
        }
    }
    
    var icon: String {
        switch self {
        case .fajr: return "moon.stars.fill"
        case .sunrise: return "sunrise.fill"
        case .dhuhr: return "sun.max.fill"
        case .asr: return "sun.min.fill"
        case .maghrib: return "sunset.fill"
        case .isha: return "moon.fill"
        }
    }
    
    var isObligatoryPrayer: Bool {
        switch self {
        case .fajr, .dhuhr, .asr, .maghrib, .isha:
            return true
        case .sunrise:
            return false
        }
    }
}

struct DailyPrayerTimes {
    let date: Date
    let prayers: [PrayerTime]
    let location: PrayerLocation
    let calculationMethod: CalculationMethod
    
    init(date: Date, prayers: [PrayerTime], location: PrayerLocation, calculationMethod: CalculationMethod) {
        self.date = date
        self.prayers = prayers
        self.location = location
        self.calculationMethod = calculationMethod
    }
    
    func prayer(for name: PrayerName) -> PrayerTime? {
        return prayers.first { $0.name == name }
    }
    
    var nextPrayer: PrayerTime? {
        let now = Date()
        return prayers
            .filter { $0.adjustedTime > now }
            .min { $0.adjustedTime < $1.adjustedTime }
    }
    
    var currentPrayer: PrayerTime? {
        return prayers.first { $0.isCurrent }
    }
    
    var obligatoryPrayers: [PrayerTime] {
        return prayers.filter { $0.name.isObligatoryPrayer }
    }
}

struct PrayerLocation: Codable {
    let latitude: Double
    let longitude: Double
    let city: String?
    let country: String?
    let timezone: String?
    
    init(latitude: Double, longitude: Double, city: String? = nil, country: String? = nil, timezone: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.country = country
        self.timezone = timezone
    }
}

enum CalculationMethod: String, CaseIterable, Codable {
    case worldIslamicLeague = "2"
    case islamicSocietyOfNorthAmerica = "3"
    case muslimWorldLeague = "4"
    case ummAlQura = "5"
    case egyptianGeneralAuthorityOfSurvey = "6"
    case universityOfIslamicSciencesKarachi = "1"
    case institutOfGeophysicsUniversityOfTehran = "7"
    case algerianMinisterOfReligiousAffairs = "8"
    case gulfRegion = "9"
    case kuwait = "10"
    case qatar = "11"
    case majlisUgamaIslamSingapore = "12"
    case unionOfIslamicOrganizationsOfFrance = "13"
    case diyanetIsleriTurkiye = "14"
    case spiritualAdministrationOfMuslimsOfRussia = "15"
    
    var displayName: String {
        switch self {
        case .worldIslamicLeague:
            return "World Islamic League"
        case .islamicSocietyOfNorthAmerica:
            return "Islamic Society of North America"
        case .muslimWorldLeague:
            return "Muslim World League"
        case .ummAlQura:
            return "Umm Al-Qura University, Makkah"
        case .egyptianGeneralAuthorityOfSurvey:
            return "Egyptian General Authority of Survey"
        case .universityOfIslamicSciencesKarachi:
            return "University of Islamic Sciences, Karachi"
        case .institutOfGeophysicsUniversityOfTehran:
            return "Institute of Geophysics, University of Tehran"
        case .algerianMinisterOfReligiousAffairs:
            return "Algerian Minister of Religious Affairs"
        case .gulfRegion:
            return "Gulf Region"
        case .kuwait:
            return "Kuwait"
        case .qatar:
            return "Qatar"
        case .majlisUgamaIslamSingapore:
            return "Majlis Ugama Islam Singapura"
        case .unionOfIslamicOrganizationsOfFrance:
            return "Union of Islamic Organizations of France"
        case .diyanetIsleriTurkiye:
            return "Diyanet İşleri Türkiye"
        case .spiritualAdministrationOfMuslimsOfRussia:
            return "Spiritual Administration of Muslims of Russia"
        }
    }
    
    var description: String {
        switch self {
        case .worldIslamicLeague:
            return "Standard method used worldwide"
        case .islamicSocietyOfNorthAmerica:
            return "Commonly used in North America"
        case .muslimWorldLeague:
            return "Former World Islamic League method"
        case .ummAlQura:
            return "Used in Saudi Arabia"
        case .egyptianGeneralAuthorityOfSurvey:
            return "Used in Egypt and nearby regions"
        case .universityOfIslamicSciencesKarachi:
            return "Used in Pakistan and India"
        default:
            return "Regional calculation method"
        }
    }
    
    nonisolated static var `default`: CalculationMethod {
        return .worldIslamicLeague
    }
}