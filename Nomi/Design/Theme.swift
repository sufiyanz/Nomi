import SwiftUI

// MARK: - Theme

enum Theme {
    
    // MARK: - Colors
    
    enum Colors {
        // Primary
        static let background = Color("Background")
        static let backgroundFallback = Color(red: 0.165, green: 0.165, blue: 0.165)
        
        static let primary = Color("Primary")
        static let primaryFallback = Color(red: 1.0, green: 0.714, blue: 0.757) // Pink #FFB6C1
        
        static let accent = Color.accentColor
        
        // Text
        static let textPrimary = Color.white
        static let textSecondary = Color.gray
        static let textMuted = Color(white: 0.5)
        
        // Cards
        static let cardBackground = Color(red: 0.96, green: 0.94, blue: 0.90) // Cream/beige
        static let cardText = Color.black
        
        // Semantic
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let destructive = Color.red
        
        // Grid pattern
        static let gridDot = Color.white.opacity(0.1)
    }
    
    // MARK: - Typography
    
    enum Typography {
        // Headlines - Serif
        static func headline(_ size: CGFloat = 28) -> Font {
            .system(size: size, weight: .bold, design: .serif)
        }
        
        static func title(_ size: CGFloat = 22) -> Font {
            .system(size: size, weight: .semibold, design: .serif)
        }
        
        // Body - Rounded
        static func body(_ size: CGFloat = 16) -> Font {
            .system(size: size, weight: .regular, design: .rounded)
        }
        
        static func bodyBold(_ size: CGFloat = 16) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }
        
        // Caption
        static func caption(_ size: CGFloat = 12) -> Font {
            .system(size: size, weight: .regular, design: .rounded)
        }
        
        // Word display - Large
        static func wordLarge(_ size: CGFloat = 32) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
        
        static func wordMedium(_ size: CGFloat = 24) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }
        
        // Romanization
        static func romanization(_ size: CGFloat = 16) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }
    }
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
        static let circle: CGFloat = 9999
    }
    
    // MARK: - Shadows
    
    enum Shadow {
        static let small = (color: Color.black.opacity(0.1), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Color.black.opacity(0.15), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let large = (color: Color.black.opacity(0.2), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
        static let bouncy = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.6)
    }
}

// MARK: - Color Extensions

extension Color {
    static let nomiBackground = Theme.Colors.backgroundFallback
    static let nomiPrimary = Theme.Colors.primaryFallback
    static let nomiCard = Theme.Colors.cardBackground
}

// MARK: - View Extensions

extension View {
    func nomiBackground() -> some View {
        self.background(Theme.Colors.backgroundFallback)
    }
    
    func cardStyle() -> some View {
        self
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.large))
            .shadow(
                color: Theme.Shadow.medium.color,
                radius: Theme.Shadow.medium.radius,
                x: Theme.Shadow.medium.x,
                y: Theme.Shadow.medium.y
            )
    }
}
