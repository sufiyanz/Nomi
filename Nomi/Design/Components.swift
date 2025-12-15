import SwiftUI

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(title)
                    .font(Theme.Typography.bodyBold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
            .background(Theme.Colors.primaryFallback)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.large))
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.bodyBold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.md)
                .background(Color.clear)
                .foregroundColor(Theme.Colors.primaryFallback)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                        .stroke(Theme.Colors.primaryFallback, lineWidth: 2)
                )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Icon Button

struct IconButton: View {
    let systemName: String
    let action: () -> Void
    var size: CGFloat = 24
    var color: Color = Theme.Colors.textPrimary
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
    }
}

// MARK: - Close Button

struct CloseButton: View {
    let action: () -> Void
    var backgroundColor: Color = Theme.Colors.backgroundFallback
    var foregroundColor: Color = Theme.Colors.primaryFallback
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(foregroundColor)
                .frame(width: 32, height: 32)
                .background(backgroundColor)
                .clipShape(Circle())
        }
    }
}

// MARK: - Audio Button

struct AudioButton: View {
    let action: () -> Void
    var isPlaying: Bool = false
    var size: CGFloat = 24
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isPlaying ? "speaker.wave.2.fill" : "speaker.wave.2")
                .font(.system(size: size, weight: .medium))
                .foregroundColor(Theme.Colors.primaryFallback)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
    }
}

// MARK: - Dotted Grid Background

struct DottedGridBackground: View {
    var dotSize: CGFloat = 2
    var spacing: CGFloat = 20
    var dotColor: Color = Theme.Colors.gridDot
    
    var body: some View {
        GeometryReader { geometry in
            let columns = Int(geometry.size.width / spacing) + 1
            let rows = Int(geometry.size.height / spacing) + 1
            
            Canvas { context, size in
                for row in 0..<rows {
                    for column in 0..<columns {
                        let x = CGFloat(column) * spacing
                        let y = CGFloat(row) * spacing
                        
                        context.fill(
                            Circle().path(in: CGRect(
                                x: x - dotSize / 2,
                                y: y - dotSize / 2,
                                width: dotSize,
                                height: dotSize
                            )),
                            with: .color(dotColor)
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Sticker Image

struct StickerImage: View {
    let name: String
    var size: CGFloat = 80
    var showCheckmark: Bool = false
    var opacity: Double = 1.0
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Placeholder sticker (emoji for now, replace with actual assets)
            Circle()
                .fill(Theme.Colors.cardBackground)
                .frame(width: size, height: size)
                .overlay(
                    Text(emojiForSticker(name))
                        .font(.system(size: size * 0.5))
                )
                .opacity(opacity)
            
            if showCheckmark {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: size * 0.25))
                    .foregroundColor(.green)
                    .background(Circle().fill(.white).padding(2))
                    .offset(x: 4, y: 4)
            }
        }
    }
    
    private func emojiForSticker(_ name: String) -> String {
        // Map sticker names to emojis as placeholders
        let mapping: [String: String] = [
            "coffee_cup": "☕️",
            "croissant": "🥐",
            "tea": "🍵",
            "menu": "📋",
            "chair": "🪑",
            "table": "🪵",
            "laptop": "💻",
            "book": "📖",
            "lamp": "💡",
            "sofa": "🛋️",
            "tv": "📺",
            "plant": "🪴",
            "bed": "🛏️",
            "pillow": "🛋️",
            "fork": "🍴",
            "spoon": "🥄",
            "plate": "🍽️",
            "glass": "🥛",
            "napkin": "🧻",
            "default": "⭐️"
        ]
        return mapping[name] ?? mapping["default"]!
    }
}

// MARK: - Streak Badge

struct StreakBadge: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xxs) {
            Text("🔥")
                .font(.system(size: 20))
            Text("\(count)")
                .font(Theme.Typography.bodyBold(18))
                .foregroundColor(Theme.Colors.textPrimary)
        }
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs)
        .background(Color.black.opacity(0.3))
        .clipShape(Capsule())
    }
}

// MARK: - Progress Badge

struct ProgressBadge: View {
    let current: Int
    let total: Int
    
    var body: some View {
        Text("\(current)/\(total)")
            .font(Theme.Typography.caption(14))
            .foregroundColor(Theme.Colors.textSecondary)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xxs)
            .background(Color.black.opacity(0.3))
            .clipShape(Capsule())
    }
}

// MARK: - Language Badge

struct LanguageBadge: View {
    let language: Language
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.xs) {
                Text(language.flag)
                    .font(.system(size: 20))
                Text(language.displayName)
                    .font(Theme.Typography.body(14))
                    .foregroundColor(Theme.Colors.textPrimary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(Color.black.opacity(0.3))
            .clipShape(Capsule())
        }
    }
}

// MARK: - Difficulty Button

struct DifficultyButton: View {
    let difficulty: ReviewDifficulty
    let action: () -> Void
    var isSelected: Bool = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.xxs) {
                Text(difficulty.emoji)
                    .font(.system(size: 28))
                Text(difficulty.displayName)
                    .font(Theme.Typography.caption(12))
                    .foregroundColor(isSelected ? .white : Theme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.sm)
            .background(isSelected ? Theme.Colors.primaryFallback : Color.black.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Got it") {}
        SecondaryButton(title: "Skip") {}
        
        HStack {
            IconButton(systemName: "arrow.left") {}
            AudioButton(action: {})
            CloseButton(action: {})
        }
        
        StreakBadge(count: 5)
        ProgressBadge(current: 3, total: 19)
        LanguageBadge(language: .japanese) {}
        
        HStack {
            ForEach(ReviewDifficulty.allCases, id: \.rawValue) { diff in
                DifficultyButton(difficulty: diff, action: {})
            }
        }
        
        StickerImage(name: "coffee_cup", size: 100, showCheckmark: true)
    }
    .padding()
    .background(Theme.Colors.backgroundFallback)
}
