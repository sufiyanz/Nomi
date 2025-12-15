import SwiftUI
import SwiftData

// MARK: - Spaces Home View

struct SpacesHomeView: View {
    
    @Environment(AppState.self) private var appState
    @Query private var stickerWords: [StickerWord]
    
    @State private var currentIndex: Int = 0
    
    var body: some View {
        @Bindable var state = appState
        
        ZStack {
            // Background
            Theme.Colors.backgroundFallback
                .ignoresSafeArea()
            
            DottedGridBackground()
                .ignoresSafeArea()
            
            // Floating decorative stickers
            floatingStickers
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                Spacer()
                
                // Spaces carousel
                spacesCarousel
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            // Settings button
            IconButton(systemName: "gearshape.fill", action: {
                appState.showSettings = true
            })
            
            Spacer()
            
            // Streak badge
            StreakBadge(count: appState.streakCount)
            
            Spacer()
            
            // Language picker
            LanguageBadge(language: appState.currentLanguage) {
                appState.showLanguagePicker = true
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.top, Theme.Spacing.md)
    }
    
    // MARK: - Spaces Carousel
    
    private var spacesCarousel: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(Location.allCases.enumerated()), id: \.element.id) { index, location in
                SpaceCard(
                    location: location,
                    progress: progressForLocation(location),
                    total: totalWordsForLocation(location),
                    onTap: {
                        appState.openSpace(location)
                    }
                )
                .tag(index)
                .padding(.horizontal, Theme.Spacing.xl)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 400)
    }
    
    // MARK: - Floating Stickers
    
    private var floatingStickers: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Group {
                // Decorative floating stickers
                Circle()
                    .fill(Theme.Colors.cardBackground)
                    .frame(width: 45, height: 45)
                    .overlay(Text("🍵").font(.system(size: 22)))
                    .position(x: width * 0.1, y: height * 0.15)
                    .floating(amplitude: 8, duration: 3.0, delay: 0)
                
                Circle()
                    .fill(Theme.Colors.cardBackground)
                    .frame(width: 50, height: 50)
                    .overlay(Text("📖").font(.system(size: 25)))
                    .position(x: width * 0.9, y: height * 0.2)
                    .floating(amplitude: 10, duration: 2.8, delay: 0.5)
                
                Circle()
                    .fill(Theme.Colors.cardBackground)
                    .frame(width: 40, height: 40)
                    .overlay(Text("🥐").font(.system(size: 20)))
                    .position(x: width * 0.08, y: height * 0.85)
                    .floating(amplitude: 9, duration: 3.2, delay: 0.3)
                
                Circle()
                    .fill(Theme.Colors.cardBackground)
                    .frame(width: 55, height: 55)
                    .overlay(Text("☕️").font(.system(size: 28)))
                    .position(x: width * 0.92, y: height * 0.82)
                    .floating(amplitude: 11, duration: 2.9, delay: 0.7)
            }
            .opacity(0.8)
        }
    }
    
    // MARK: - Helpers
    
    private func progressForLocation(_ location: Location) -> Int {
        stickerWords
            .filter { $0.location == location.rawValue && $0.isCollected }
            .count
    }
    
    private func totalWordsForLocation(_ location: Location) -> Int {
        // Get from predefined vocabulary
        PredefinedVocabulary.words(for: location).count
    }
}

// MARK: - Space Card

struct SpaceCard: View {
    
    let location: Location
    let progress: Int
    let total: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Theme.Spacing.lg) {
                // Icon/illustration area
                ZStack {
                    Circle()
                        .fill(Theme.Colors.cardBackground)
                        .frame(width: 140, height: 140)
                    
                    Text(location.emoji)
                        .font(.system(size: 70))
                }
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // Space name
                Text(location.displayName)
                    .font(Theme.Typography.title(24))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                // Progress
                ProgressBadge(current: progress, total: total)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.xxl)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.xlarge)
                    .fill(Color.black.opacity(0.3))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SpacesHomeView()
            .environment(AppState())
            .modelContainer(for: StickerWord.self, inMemory: true)
    }
}
