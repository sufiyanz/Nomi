//
//  Location.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import Foundation

enum Location: String, CaseIterable, Identifiable, Codable {
    case cafe
    case restaurant
    case store
    case station
    case home
    case park
    case hospital
    case office
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .cafe: return "Cafe"
        case .restaurant: return "Restaurant"
        case .store: return "Store"
        case .station: return "Station"
        case .home: return "Home"
        case .park: return "Park"
        case .hospital: return "Hospital"
        case .office: return "Office"
        }
    }
    
    var icon: String {
        switch self {
        case .cafe: return "☕"
        case .restaurant: return "🍜"
        case .store: return "🛒"
        case .station: return "🚉"
        case .home: return "🏠"
        case .park: return "🌳"
        case .hospital: return "🏥"
        case .office: return "🏢"
        }
    }
    
    var description: String {
        switch self {
        case .cafe: return "Coffee, drinks, pastries, ordering"
        case .restaurant: return "Food, dining, reservations"
        case .store: return "Shopping, prices, products"
        case .station: return "Transportation, directions, tickets"
        case .home: return "Household items, family, daily life"
        case .park: return "Nature, activities, weather"
        case .hospital: return "Health, body, emergencies"
        case .office: return "Work, business, meetings"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .cafe: return 0
        case .restaurant: return 1
        case .store: return 2
        case .station: return 3
        case .home: return 4
        case .park: return 5
        case .hospital: return 6
        case .office: return 7
        }
    }
    
    var promptContext: String {
        switch self {
        case .cafe:
            return "a cafe or coffee shop setting - include words for coffee drinks, tea, pastries, ordering, seating, and cafe items"
        case .restaurant:
            return "a restaurant or dining setting - include words for food, menu items, ordering, utensils, and dining etiquette"
        case .store:
            return "a store or shopping setting - include words for products, prices, payment, shopping, and common store items"
        case .station:
            return "a train/bus station or transportation setting - include words for tickets, platforms, directions, schedules, and travel"
        case .home:
            return "a home or household setting - include words for rooms, furniture, family members, daily activities, and household items"
        case .park:
            return "a park or outdoor nature setting - include words for nature, weather, outdoor activities, plants, and animals"
        case .hospital:
            return "a hospital or medical setting - include words for health, body parts, symptoms, medicine, and medical situations"
        case .office:
            return "an office or workplace setting - include words for work, meetings, office supplies, colleagues, and business activities"
        }
    }
    
    // Kawaii color theme for each location
    var themeColor: String {
        switch self {
        case .cafe: return "#D4A574"      // Warm brown
        case .restaurant: return "#FF6B6B" // Coral red
        case .store: return "#4ECDC4"      // Teal
        case .station: return "#45B7D1"    // Sky blue
        case .home: return "#96CEB4"       // Sage green
        case .park: return "#88D8B0"       // Mint
        case .hospital: return "#FFB6C1"   // Light pink
        case .office: return "#DDA0DD"     // Plum
        }
    }
    
    /// Asset name for the pre-generated kawaii sticker
    var stickerAssetName: String {
        return rawValue // e.g., "cafe", "restaurant", etc.
    }
}
