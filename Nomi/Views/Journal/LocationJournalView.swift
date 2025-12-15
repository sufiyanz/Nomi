import SwiftUI
import SwiftData

// MARK: - Space Detail View (Canvas)

struct SpaceDetailView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let location: Location
    
    @Query private var allStickerWords: [StickerWord]
    @State private var selectedTab: SpaceTab = .canvas
    @State private var selectedWord: StickerWord?
    @State private var showWordCard = false
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private var stickerWords: [StickerWord] {
        allStickerWords.filter { $0.location == location.rawValue }
    }
    
    private var collectedCount: Int {
        stickerWords.filter { $0.isCollected }.count
    }
    
    var body: some View {
        ZStack {
            // Background
            Theme.Colors.backgroundFallback
                .ignoresSafeArea()
            
            DottedGridBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header (since we hide the nav bar)
                headerView
                
                // Content based on selected tab
                if selectedTab == .canvas {
                    canvasView
                } else {
                    reviewListView
                }
                
                // Bottom tab bar
                tabBar
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showWordCard) {
            if let word = selectedWord {
                WordCardView(
                    stickerWord: word,
                    language: appState.currentLanguage,
                    onCollect: {
                        collectWord(word)
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            initializeStickerWords()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            // Back button
            IconButton(systemName: "arrow.left", action: {
                dismiss()
            })
            
            Spacer()
            
            // Title
            Text(location.displayName)
                .font(Theme.Typography.title(20))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Spacer()
            
            // Progress
            ProgressBadge(current: collectedCount, total: stickerWords.count)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
    }
    
    // MARK: - Canvas View
    
    private var canvasView: some View {
        GeometryReader { geometry in
            let canvasSize = CGSize(
                width: geometry.size.width * 2,
                height: geometry.size.height * 2
            )
            
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ZStack {
                    // Canvas background
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: canvasSize.width, height: canvasSize.height)
                    
                    // Stickers
                    ForEach(stickerWords) { word in
                        stickerView(for: word, in: canvasSize)
                    }
                }
            }
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = min(max(value, 0.5), 2.0)
                    }
            )
            .scaleEffect(scale)
        }
    }
    
    private func stickerView(for word: StickerWord, in canvasSize: CGSize) -> some View {
        let x = word.positionX * canvasSize.width
        let y = word.positionY * canvasSize.height
        
        return Button(action: {
            selectedWord = word
            showWordCard = true
            appState.hapticService.mediumImpact()
        }) {
            StickerImage(
                name: word.wordKey,
                size: 80,
                showCheckmark: word.isCollected,
                opacity: word.isCollected ? 0.6 : 1.0
            )
        }
        .position(x: x, y: y)
        .scaleAppear(delay: Double.random(in: 0...0.5))
    }
    
    // MARK: - Review List View
    
    private var reviewListView: some View {
        ScrollView {
            if stickerWords.filter({ $0.isCollected }).isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: Theme.Spacing.sm) {
                    ForEach(stickerWords.filter { $0.isCollected }) { word in
                        CollectedWordRow(word: word) {
                            selectedWord = word
                            showWordCard = true
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text("🔍")
                .font(.system(size: 60))
            
            Text("No words collected yet")
                .font(Theme.Typography.title(18))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("Explore the canvas to find and collect words!")
                .font(Theme.Typography.body(14))
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Theme.Spacing.xl)
    }
    
    // MARK: - Tab Bar
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "square.grid.2x2",
                isSelected: selectedTab == .canvas,
                action: { selectedTab = .canvas }
            )
            
            TabBarButton(
                icon: "list.bullet",
                isSelected: selectedTab == .review,
                action: { selectedTab = .review }
            )
        }
        .padding(.vertical, Theme.Spacing.sm)
        .background(Color.black.opacity(0.3))
    }
    
    // MARK: - Helpers
    
    private func initializeStickerWords() {
        // Only create if not already existing
        guard stickerWords.isEmpty else { return }
        
        let words = PredefinedVocabulary.words(for: location)
        let positions = generateRandomPositions(count: words.count)
        
        for (index, word) in words.enumerated() {
            let stickerWord = StickerWord(
                wordKey: word.lowercased().replacingOccurrences(of: " ", with: "_"),
                location: location,
                positionX: positions[index].x,
                positionY: positions[index].y
            )
            modelContext.insert(stickerWord)
        }
        
        try? modelContext.save()
    }
    
    private func generateRandomPositions(count: Int) -> [CGPoint] {
        var positions: [CGPoint] = []
        let minDistance: CGFloat = 0.12
        
        for _ in 0..<count {
            var newPosition: CGPoint
            var attempts = 0
            
            repeat {
                newPosition = CGPoint(
                    x: CGFloat.random(in: 0.1...0.9),
                    y: CGFloat.random(in: 0.1...0.9)
                )
                attempts += 1
            } while positions.contains(where: { distance($0, newPosition) < minDistance }) && attempts < 100
            
            positions.append(newPosition)
        }
        
        return positions
    }
    
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }
    
    private func collectWord(_ word: StickerWord) {
        word.collect()
        showWordCard = false
        appState.hapticService.success()
    }
}

// MARK: - Space Tab

enum SpaceTab {
    case canvas
    case review
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isSelected ? icon + ".fill" : icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? Theme.Colors.primaryFallback : Theme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.sm)
        }
    }
}

// MARK: - Collected Word Row

struct CollectedWordRow: View {
    let word: StickerWord
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.md) {
                StickerImage(name: word.wordKey, size: 50)
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(word.wordKey.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(Theme.Typography.bodyBold(16))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    if let collectedAt = word.collectedAt {
                        Text("Collected \(collectedAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(Theme.Typography.caption(12))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Colors.textMuted)
            }
            .padding(Theme.Spacing.md)
            .background(Color.black.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SpaceDetailView(location: .cafe)
            .environment(AppState())
            .modelContainer(for: StickerWord.self, inMemory: true)
    }
}
