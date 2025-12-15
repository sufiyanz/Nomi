import Foundation
import SwiftData

// MARK: - Language

enum Language: String, CaseIterable, Codable, Identifiable {
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case japanese = "ja"
    case italian = "it"
    case korean = "ko"
    case mandarin = "zh"
    case portuguese = "pt"
    case russian = "ru"
    case arabic = "ar"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .japanese: return "Japanese"
        case .italian: return "Italian"
        case .korean: return "Korean"
        case .mandarin: return "Mandarin Chinese"
        case .portuguese: return "Portuguese"
        case .russian: return "Russian"
        case .arabic: return "Arabic"
        }
    }
    
    var flag: String {
        switch self {
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .japanese: return "🇯🇵"
        case .italian: return "🇮🇹"
        case .korean: return "🇰🇷"
        case .mandarin: return "🇨🇳"
        case .portuguese: return "🇧🇷"
        case .russian: return "🇷🇺"
        case .arabic: return "🇸🇦"
        }
    }
    
    var languageCode: String {
        switch self {
        case .spanish: return "es-ES"
        case .french: return "fr-FR"
        case .german: return "de-DE"
        case .japanese: return "ja-JP"
        case .italian: return "it-IT"
        case .korean: return "ko-KR"
        case .mandarin: return "zh-CN"
        case .portuguese: return "pt-BR"
        case .russian: return "ru-RU"
        case .arabic: return "ar-SA"
        }
    }
    
    /// Whether this language uses romanization (non-Latin scripts)
    var usesRomanization: Bool {
        switch self {
        case .japanese, .korean, .mandarin, .russian, .arabic:
            return true
        default:
            return false
        }
    }
}
