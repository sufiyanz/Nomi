//
//  Language.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import Foundation

enum Language: String, CaseIterable, Identifiable, Codable {
    case japanese
    case korean
    case spanish
    case french
    case german
    case italian
    case portuguese
    case chinese
    case arabic
    case hindi
    case russian
    case dutch
    case swedish
    case turkish
    case vietnamese
    case thai
    case indonesian
    case polish
    case greek
    case hebrew
    
    var id: String { rawValue }
    
    var code: String {
        switch self {
        case .japanese: return "ja"
        case .korean: return "ko"
        case .spanish: return "es"
        case .french: return "fr"
        case .german: return "de"
        case .italian: return "it"
        case .portuguese: return "pt"
        case .chinese: return "zh"
        case .arabic: return "ar"
        case .hindi: return "hi"
        case .russian: return "ru"
        case .dutch: return "nl"
        case .swedish: return "sv"
        case .turkish: return "tr"
        case .vietnamese: return "vi"
        case .thai: return "th"
        case .indonesian: return "id"
        case .polish: return "pl"
        case .greek: return "el"
        case .hebrew: return "he"
        }
    }
    
    var name: String {
        switch self {
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .chinese: return "Mandarin Chinese"
        case .arabic: return "Arabic"
        case .hindi: return "Hindi"
        case .russian: return "Russian"
        case .dutch: return "Dutch"
        case .swedish: return "Swedish"
        case .turkish: return "Turkish"
        case .vietnamese: return "Vietnamese"
        case .thai: return "Thai"
        case .indonesian: return "Indonesian"
        case .polish: return "Polish"
        case .greek: return "Greek"
        case .hebrew: return "Hebrew"
        }
    }
    
    var nativeName: String {
        switch self {
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .portuguese: return "Português"
        case .chinese: return "中文"
        case .arabic: return "العربية"
        case .hindi: return "हिन्दी"
        case .russian: return "Русский"
        case .dutch: return "Nederlands"
        case .swedish: return "Svenska"
        case .turkish: return "Türkçe"
        case .vietnamese: return "Tiếng Việt"
        case .thai: return "ไทย"
        case .indonesian: return "Bahasa Indonesia"
        case .polish: return "Polski"
        case .greek: return "Ελληνικά"
        case .hebrew: return "עברית"
        }
    }
    
    var flagEmoji: String {
        switch self {
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .italian: return "🇮🇹"
        case .portuguese: return "🇵🇹"
        case .chinese: return "🇨🇳"
        case .arabic: return "🇸🇦"
        case .hindi: return "🇮🇳"
        case .russian: return "🇷🇺"
        case .dutch: return "🇳🇱"
        case .swedish: return "🇸🇪"
        case .turkish: return "🇹🇷"
        case .vietnamese: return "🇻🇳"
        case .thai: return "🇹🇭"
        case .indonesian: return "🇮🇩"
        case .polish: return "🇵🇱"
        case .greek: return "🇬🇷"
        case .hebrew: return "🇮🇱"
        }
    }
    
    var voiceIdentifier: String {
        switch self {
        case .japanese: return "ja-JP"
        case .korean: return "ko-KR"
        case .spanish: return "es-ES"
        case .french: return "fr-FR"
        case .german: return "de-DE"
        case .italian: return "it-IT"
        case .portuguese: return "pt-PT"
        case .chinese: return "zh-CN"
        case .arabic: return "ar-SA"
        case .hindi: return "hi-IN"
        case .russian: return "ru-RU"
        case .dutch: return "nl-NL"
        case .swedish: return "sv-SE"
        case .turkish: return "tr-TR"
        case .vietnamese: return "vi-VN"
        case .thai: return "th-TH"
        case .indonesian: return "id-ID"
        case .polish: return "pl-PL"
        case .greek: return "el-GR"
        case .hebrew: return "he-IL"
        }
    }
    
    var hasRomanization: Bool {
        switch self {
        case .japanese, .korean, .chinese, .arabic, .hindi, .russian, .thai, .greek, .hebrew:
            return true
        default:
            return false
        }
    }
}
