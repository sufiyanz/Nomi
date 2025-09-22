import SwiftUI

struct DesignTokens {
    // Base spacing units
    static let spacing: CGFloat = 12

    // Container spacing used by GlassEffectContainer and similar wrappers
    static let containerSpacing: CGFloat = 20

    // Standard corner radius for glass cards and containers
    static let cornerRadius: CGFloat = 12
    
    // Card padding for consistent spacing
    static let cardPadding: CGFloat = 20
    
    // Animation constants
    static let animationDuration: Double = 0.3
    static let springAnimation: Animation = .spring(response: 0.6, dampingFraction: 0.8)
}

// MARK: - Glass Effect Container
struct GlassEffectContainer<Content: View>: View {
    let content: Content
    let spacing: CGFloat
    
    init(spacing: CGFloat = DesignTokens.containerSpacing, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.spacing = spacing
    }
    
    var body: some View {
        content
            .padding(DesignTokens.cardPadding)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                    .strokeBorder(Color.glassBorder, lineWidth: 0.5)
            )
    }
}

// MARK: - Adaptive Colors for Light/Dark Mode
extension Color {
    // Card backgrounds that adapt to light/dark mode
    static let cardBackground = Color(.systemBackground).opacity(0.8)
    static let cardSecondaryBackground = Color(.secondarySystemBackground)
    
    // Glass effect materials
    static let glassPrimary = Color(.systemBackground).opacity(0.1)
    static let glassSecondary = Color(.systemBackground).opacity(0.05)
    
    // Border colors
    static let cardBorder = Color(.separator).opacity(0.3)
    static let glassBorder = Color.primary.opacity(0.1)
    
    // Text colors (these are already adaptive but explicit for clarity)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(.tertiaryLabel)
    
    // Accent colors for different card types
    static let timeAccent = Color.blue
    static let dateAccent = Color.green
    static let prayerAccent = Color.purple
    static let summaryAccent = Color.orange
    static let scheduleAccent = Color.indigo
}
