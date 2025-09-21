import SwiftUI

struct CalendarView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                GlassEffectContainer(spacing: DesignTokens.containerSpacing) {
                    VStack(spacing: 12) {
                        Text("Calendar")
                            .font(.largeTitle)
                        Text("Day/Week/Month mock views and filters will go here.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    CalendarView()
}
