//
//  Theme.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import SwiftUI

// MARK: - Color Theme
extension Color {
    // Primary kawaii colors
    static let nomiPink = Color(hex: "FFB6C1")
    static let nomiCream = Color(hex: "FFF8DC")
    static let nomiMint = Color(hex: "98FF98")
    static let nomiLavender = Color(hex: "E6E6FA")
    static let nomiPeach = Color(hex: "FFDAB9")
    static let nomiSky = Color(hex: "87CEEB")
    
    // Text colors
    static let nomiText = Color(hex: "4A4A4A")
    static let nomiTextLight = Color(hex: "7A7A7A")
    static let nomiTextDark = Color(hex: "2A2A2A")
    
    // Background colors
    static let nomiBackground = Color(hex: "FFFEF9")
    static let nomiPaper = Color(hex: "FDF6E3")
    static let nomiCardBackground = Color.white
    
    // Accent colors
    static let nomiAccent = Color(hex: "FF8FAB")
    static let nomiSuccess = Color(hex: "77DD77")
    static let nomiWarning = Color(hex: "FFD93D")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography
extension Font {
    static func nomiTitle() -> Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }
    
    static func nomiHeadline() -> Font {
        .system(size: 22, weight: .semibold, design: .rounded)
    }
    
    static func nomiSubheadline() -> Font {
        .system(size: 18, weight: .medium, design: .rounded)
    }
    
    static func nomiBody() -> Font {
        .system(size: 16, weight: .regular, design: .rounded)
    }
    
    static func nomiCaption() -> Font {
        .system(size: 14, weight: .regular, design: .rounded)
    }
    
    static func nomiLarge() -> Font {
        .system(size: 34, weight: .bold, design: .rounded)
    }
    
    static func nomiWord() -> Font {
        .system(size: 42, weight: .bold, design: .rounded)
    }
}

// MARK: - Shadows
extension View {
    func nomiShadow(radius: CGFloat = 8, y: CGFloat = 4) -> some View {
        self.shadow(
            color: Color.black.opacity(0.08),
            radius: radius,
            x: 0,
            y: y
        )
    }
    
    func stickerShadow() -> some View {
        self.shadow(
            color: Color.black.opacity(0.15),
            radius: 4,
            x: 2,
            y: 3
        )
    }
}

// MARK: - Gradients
extension LinearGradient {
    static let nomiBackground = LinearGradient(
        colors: [Color.nomiCream, Color.nomiBackground],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let nomiPinkGradient = LinearGradient(
        colors: [Color.nomiPink, Color.nomiPeach],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let nomiMintGradient = LinearGradient(
        colors: [Color.nomiMint, Color.nomiSky],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Corner Radius
enum NomiRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
}

// MARK: - Spacing
enum NomiSpacing {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
    static let huge: CGFloat = 48
}
