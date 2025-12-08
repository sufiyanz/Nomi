//
//  Components.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import SwiftUI

// MARK: - Kawaii Button
struct KawaiiButton: View {
    let title: String
    var icon: String? = nil
    var style: ButtonStyle = .primary
    var isLoading: Bool = false
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
        case outline
        case ghost
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .nomiPink
            case .secondary: return .nomiMint
            case .outline: return .clear
            case .ghost: return .clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return .nomiTextDark
            case .outline: return .nomiPink
            case .ghost: return .nomiText
            }
        }
        
        var hasBorder: Bool {
            self == .outline
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: NomiSpacing.small) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Text(icon)
                    }
                    Text(title)
                        .font(.nomiSubheadline())
                }
            }
            .foregroundColor(style.foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, NomiSpacing.medium)
            .padding(.horizontal, NomiSpacing.large)
            .background(style.backgroundColor)
            .cornerRadius(NomiRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: NomiRadius.large)
                    .stroke(style.hasBorder ? Color.nomiPink : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(BouncePressStyle())
        .disabled(isLoading)
    }
}

// MARK: - Sticker View
struct StickerView: View {
    let word: StickerWord
    var size: StickerSize = .medium
    var showLabel: Bool = true
    
    enum StickerSize {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 60
            case .medium: return 100
            case .large: return 150
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 16
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Sticker image or placeholder
            ZStack {
                Circle()
                    .fill(Color(hex: word.location?.themeColor ?? "#FFB6C1").opacity(0.3))
                    .frame(width: size.dimension, height: size.dimension)
                
                if let imageData = word.stickerImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size.dimension * 0.8, height: size.dimension * 0.8)
                } else if let emoji = word.stickerEmoji {
                    // Show saved emoji sticker
                    Text(emoji)
                        .font(.system(size: size.dimension * 0.5))
                } else {
                    // Placeholder with location emoji
                    Text(word.location?.icon ?? "✨")
                        .font(.system(size: size.dimension * 0.4))
                }
            }
            .stickerShadow()
            
            if showLabel {
                VStack(spacing: 2) {
                    Text(word.targetWord)
                        .font(.system(size: size.fontSize, weight: .semibold, design: .rounded))
                        .foregroundColor(.nomiTextDark)
                    
                    Text(word.englishWord)
                        .font(.system(size: size.fontSize - 2, weight: .regular, design: .rounded))
                        .foregroundColor(.nomiTextLight)
                }
                .multilineTextAlignment(.center)
                .lineLimit(1)
            }
        }
    }
}

// MARK: - Location Card
struct LocationCard: View {
    let location: Location
    let wordCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: NomiSpacing.small) {
                // Location sticker image
                ZStack {
                    Circle()
                        .fill(Color(hex: location.themeColor).opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    // Try to load bundled sticker, fallback to emoji
                    if let uiImage = UIImage(named: location.stickerAssetName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    } else {
                        Text(location.icon)
                            .font(.system(size: 36))
                    }
                }
                .stickerShadow()
                
                // Location name
                Text(location.name)
                    .font(.nomiSubheadline())
                    .foregroundColor(.nomiTextDark)
                
                // Word count
                Text("\(wordCount) words")
                    .font(.nomiCaption())
                    .foregroundColor(.nomiTextLight)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, NomiSpacing.medium)
            .background(Color.nomiCardBackground)
            .cornerRadius(NomiRadius.large)
            .nomiShadow()
        }
        .buttonStyle(BouncePressStyle())
    }
}

// MARK: - Language Badge
struct LanguageBadge: View {
    let language: Language
    var isSelected: Bool = false
    var showWordCount: Bool = false
    var wordCount: Int = 0
    
    var body: some View {
        HStack(spacing: NomiSpacing.small) {
            Text(language.flagEmoji)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(language.name)
                    .font(.nomiBody())
                    .foregroundColor(.nomiTextDark)
                
                if showWordCount {
                    Text("\(wordCount) words")
                        .font(.nomiCaption())
                        .foregroundColor(.nomiTextLight)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.nomiPink)
                    .font(.system(size: 20))
            }
        }
        .padding(NomiSpacing.medium)
        .background(isSelected ? Color.nomiPink.opacity(0.1) : Color.nomiCardBackground)
        .cornerRadius(NomiRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: NomiRadius.medium)
                .stroke(isSelected ? Color.nomiPink : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Paper Background
struct PaperBackground: View {
    var body: some View {
        ZStack {
            Color.nomiPaper
            
            // Subtle paper texture effect
            GeometryReader { geometry in
                Canvas { context, size in
                    // Add subtle dots for texture
                    for _ in 0..<100 {
                        let x = CGFloat.random(in: 0...size.width)
                        let y = CGFloat.random(in: 0...size.height)
                        let rect = CGRect(x: x, y: y, width: 1, height: 1)
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(Color.black.opacity(0.02))
                        )
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: NomiSpacing.large) {
            Text(icon)
                .font(.system(size: 60))
                .floating()
            
            VStack(spacing: NomiSpacing.small) {
                Text(title)
                    .font(.nomiHeadline())
                    .foregroundColor(.nomiTextDark)
                
                Text(message)
                    .font(.nomiBody())
                    .foregroundColor(.nomiTextLight)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                KawaiiButton(title: actionTitle, action: action)
                    .padding(.horizontal, NomiSpacing.extraLarge)
            }
        }
        .padding(NomiSpacing.large)
    }
}

// MARK: - Mastery Indicator
struct MasteryIndicator: View {
    let level: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { index in
                Circle()
                    .fill(index <= level ? Color.nomiPink : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let title: String
    var color: Color = .nomiPink
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: NomiSpacing.small) {
                Text(icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.nomiBody())
            }
            .foregroundColor(.white)
            .padding(.horizontal, NomiSpacing.medium)
            .padding(.vertical, NomiSpacing.small)
            .background(color)
            .cornerRadius(NomiRadius.extraLarge)
            .nomiShadow(radius: 12, y: 6)
        }
        .buttonStyle(BouncePressStyle())
    }
}

// MARK: - Previews
#Preview("Kawaii Button") {
    VStack(spacing: 20) {
        KawaiiButton(title: "Primary Button", icon: "✨", style: .primary) {}
        KawaiiButton(title: "Secondary Button", icon: "🌸", style: .secondary) {}
        KawaiiButton(title: "Outline Button", style: .outline) {}
        KawaiiButton(title: "Loading...", isLoading: true) {}
    }
    .padding()
}

#Preview("Location Card") {
    LocationCard(location: .cafe, wordCount: 12) {}
        .padding()
}

#Preview("Language Badge") {
    VStack(spacing: 12) {
        LanguageBadge(language: .japanese, isSelected: true, showWordCount: true, wordCount: 45)
        LanguageBadge(language: .korean, isSelected: false, showWordCount: true, wordCount: 23)
    }
    .padding()
}
