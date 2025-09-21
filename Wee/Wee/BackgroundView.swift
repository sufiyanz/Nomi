import SwiftUI

struct BackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var gradientColors: [Color] {
        switch colorScheme {
        case .dark:
            return [
                Color(hue: 0.62, saturation: 0.35, brightness: 0.20),
                Color(hue: 0.62, saturation: 0.25, brightness: 0.10)
            ]
        case .light:
            return [
                Color(hue: 0.62, saturation: 0.15, brightness: 0.95),
                Color(hue: 0.62, saturation: 0.20, brightness: 0.85)
            ]
        @unknown default:
            return [
                Color(hue: 0.62, saturation: 0.35, brightness: 0.20),
                Color(hue: 0.62, saturation: 0.25, brightness: 0.10)
            ]
        }
    }
}

#Preview("Dark Mode") { 
    BackgroundView()
        .preferredColorScheme(.dark)
}

#Preview("Light Mode") { 
    BackgroundView()
        .preferredColorScheme(.light)
}
