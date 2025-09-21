import SwiftUI

struct AdhanView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                GlassEffectContainer(spacing: DesignTokens.containerSpacing) {
                    VStack(spacing: 16) {
                        Text("Adhan")
                            .font(.largeTitle)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    AdhanView()
}
