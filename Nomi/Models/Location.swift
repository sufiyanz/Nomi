import Foundation

// MARK: - Location (Space)

enum Location: String, CaseIterable, Identifiable, Codable {
    case home
    case cafe
    case restaurant
    case office
    case groceryStore
    case transit
    case cinema
    case gym
    case park
    case hospital
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .home: return "Home"
        case .cafe: return "Café"
        case .restaurant: return "Restaurant"
        case .office: return "Office"
        case .groceryStore: return "Grocery Store"
        case .transit: return "Train/Transit"
        case .cinema: return "Cinema"
        case .gym: return "Gym"
        case .park: return "Park"
        case .hospital: return "Hospital/Pharmacy"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .cafe: return "cup.and.saucer.fill"
        case .restaurant: return "fork.knife"
        case .office: return "building.2.fill"
        case .groceryStore: return "cart.fill"
        case .transit: return "tram.fill"
        case .cinema: return "film.fill"
        case .gym: return "dumbbell.fill"
        case .park: return "leaf.fill"
        case .hospital: return "cross.case.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .home: return "🏠"
        case .cafe: return "☕️"
        case .restaurant: return "🍽️"
        case .office: return "🏢"
        case .groceryStore: return "🛒"
        case .transit: return "🚃"
        case .cinema: return "🎬"
        case .gym: return "🏋️"
        case .park: return "🌳"
        case .hospital: return "🏥"
        }
    }
    
    /// Sticker asset name for the location card
    var stickerName: String {
        rawValue
    }
}
