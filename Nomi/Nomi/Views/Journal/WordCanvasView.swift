//
//  WordCanvasView.swift
//  Nomi
//
//  Interactive canvas with dotted grid background for browsing vocabulary words.
//  Supports pinch-to-zoom, pan, and free-flowing draggable stickers.
//

import SwiftUI

// MARK: - Displayable Word Protocol
protocol DisplayableWord: Identifiable {
    var id: String { get }
    var targetWord: String { get }
    var romanization: String? { get }
    var englishWord: String { get }
    var exampleSentence: String? { get }
    var stickerEmoji: String { get }
    var stickerImageData: Data? { get }
    var isCollected: Bool { get }
}

// MARK: - Canvas Word Wrapper
struct CanvasWord: DisplayableWord {
    let predefined: PredefinedWord
    let collected: Bool
    var position: CGPoint // Position on canvas
    
    var id: String { predefined.englishWord.lowercased() }
    var targetWord: String { predefined.targetWord }
    var romanization: String? { predefined.romanization }
    var englishWord: String { predefined.englishWord }
    var exampleSentence: String? { predefined.exampleSentence }
    var stickerEmoji: String { predefined.stickerEmoji }
    var stickerImageData: Data? { nil }
    var isCollected: Bool { collected }
}

// MARK: - Dotted Grid Background (Scalable)
struct DottedGridBackground: View {
    let scale: CGFloat
    let offset: CGSize
    let dotSpacing: CGFloat = 24
    let dotSize: CGFloat = 3
    let dotColor: Color = Color.gray.opacity(0.2)
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Adjust spacing based on scale
                let adjustedSpacing = dotSpacing * scale
                let adjustedDotSize = max(dotSize * scale, 1.5)
                
                // Calculate visible area with offset
                let startX = -offset.width.truncatingRemainder(dividingBy: adjustedSpacing)
                let startY = -offset.height.truncatingRemainder(dividingBy: adjustedSpacing)
                
                let columns = Int(size.width / adjustedSpacing) + 2
                let rows = Int(size.height / adjustedSpacing) + 2
                
                for row in 0..<rows {
                    for col in 0..<columns {
                        let x = startX + CGFloat(col) * adjustedSpacing
                        let y = startY + CGFloat(row) * adjustedSpacing
                        
                        guard x >= -adjustedSpacing && x <= size.width + adjustedSpacing,
                              y >= -adjustedSpacing && y <= size.height + adjustedSpacing else {
                            continue
                        }
                        
                        let rect = CGRect(
                            x: x - adjustedDotSize/2,
                            y: y - adjustedDotSize/2,
                            width: adjustedDotSize,
                            height: adjustedDotSize
                        )
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(dotColor)
                        )
                    }
                }
            }
        }
        .background(Color.nomiPaper)
    }
}

// MARK: - Draggable Sticker on Canvas
struct DraggableStickerView: View {
    let word: CanvasWord
    let themeColor: Color
    let scale: CGFloat
    let onTap: () -> Void
    let onDragEnd: (CGSize) -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    
    private var stickerSize: CGFloat { 80 * scale }
    
    var body: some View {
        VStack(spacing: 4 * scale) {
            // Sticker circle
            ZStack {
                Circle()
                    .fill(themeColor.opacity(0.25))
                    .frame(width: stickerSize, height: stickerSize)
                
                if let imageData = word.stickerImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: stickerSize * 0.7, height: stickerSize * 0.7)
                } else {
                    Text(word.stickerEmoji)
                        .font(.system(size: stickerSize * 0.45))
                }
                
                // Collected indicator
                if word.isCollected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16 * scale))
                                .foregroundColor(.nomiMint)
                                .background(Circle().fill(.white).frame(width: 14 * scale, height: 14 * scale))
                        }
                        Spacer()
                    }
                    .frame(width: stickerSize, height: stickerSize)
                }
            }
            .shadow(color: .black.opacity(isDragging ? 0.25 : 0.1), radius: isDragging ? 8 : 4, y: isDragging ? 4 : 2)
            
            // Word labels
            VStack(spacing: 2 * scale) {
                // Target language word
                Text(word.targetWord)
                    .font(.system(size: max(10 * scale, 8), weight: .semibold, design: .rounded))
                    .foregroundColor(.nomiTextDark)
                    .lineLimit(1)
                
                // English translation
                Text(word.englishWord)
                    .font(.system(size: max(8 * scale, 6), weight: .regular, design: .rounded))
                    .foregroundColor(.nomiTextDark.opacity(0.6))
                    .lineLimit(1)
            }
        }
        .scaleEffect(isDragging ? 1.15 : 1.0)
        .offset(dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    dragOffset = value.translation
                }
                .onEnded { value in
                    isDragging = false
                    onDragEnd(value.translation)
                    dragOffset = .zero
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    if !isDragging {
                        HapticService.shared.tap()
                        onTap()
                    }
                }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
    }
}

// MARK: - Inline Word Card (Appears at sticker location)
struct InlineWordCard: View {
    let word: CanvasWord
    let language: Language
    let themeColor: Color
    let isCollected: Bool
    let onCollect: () -> Void
    let onDismiss: () -> Void
    
    @StateObject private var audioService = AudioService.shared
    
    var body: some View {
        VStack(spacing: NomiSpacing.medium) {
            // Close button
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            
            // Sticker
            ZStack {
                Circle()
                    .fill(themeColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                if let imageData = word.stickerImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 56, height: 56)
                } else {
                    Text(word.stickerEmoji)
                        .font(.system(size: 44))
                }
            }
            
            // Word info
            VStack(spacing: 4) {
                HStack(spacing: NomiSpacing.small) {
                    Text(word.targetWord)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.nomiTextDark)
                    
                    Button {
                        audioService.speak(word.targetWord, language: language)
                    } label: {
                        Image(systemName: audioService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.nomiPink)
                            .frame(width: 30, height: 30)
                            .background(Color.nomiPink.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(BouncePressStyle())
                }
                
                if let romanization = word.romanization {
                    Text(romanization)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.nomiTextLight)
                        .italic()
                }
                
                Text(word.englishWord)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.nomiPink)
            }
            
            // Example sentence
            if let example = word.exampleSentence {
                VStack(spacing: 6) {
                    HStack {
                        Text("Example")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.nomiTextLight)
                        Spacer()
                        
                        Button {
                            audioService.speak(example, language: language)
                        } label: {
                            Image(systemName: "speaker.wave.2")
                                .font(.system(size: 11))
                                .foregroundColor(.nomiPink)
                        }
                        .buttonStyle(BouncePressStyle())
                    }
                    
                    Text(example)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.nomiTextDark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                }
                .padding(10)
                .background(Color.nomiCream)
                .cornerRadius(NomiRadius.small)
            }
            
            // Add to journal button
            if !isCollected {
                Button(action: onCollect) {
                    HStack(spacing: NomiSpacing.tiny) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                        Text("Add to Journal")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.nomiPink)
                    .cornerRadius(NomiRadius.medium)
                }
                .buttonStyle(BouncePressStyle())
            } else {
                HStack(spacing: NomiSpacing.tiny) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                    Text("In Your Journal")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.nomiMint)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.nomiMint.opacity(0.15))
                .cornerRadius(NomiRadius.medium)
            }
        }
        .padding(NomiSpacing.medium)
        .frame(width: 260)
        .background(Color.nomiCardBackground)
        .cornerRadius(NomiRadius.large)
        .shadow(color: .black.opacity(0.2), radius: 20, y: 8)
    }
}

// MARK: - Word Canvas View
struct WordCanvasView: View {
    @Binding var words: [CanvasWord]
    let collectedWords: Set<String>
    let location: Location
    let language: Language
    let onCollectWord: (CanvasWord) -> Void
    
    @State private var selectedWord: CanvasWord?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 2.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dotted grid background (responds to zoom/pan)
                DottedGridBackground(scale: scale, offset: offset)
                
                if words.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Text(location.icon)
                            .font(.system(size: 60))
                        Text("No words available")
                            .font(.headline)
                            .foregroundColor(.nomiTextLight)
                        Text("Words for this location are being prepared.")
                            .font(.subheadline)
                            .foregroundColor(.nomiTextLight)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Free-flowing stickers
                    ForEach(Array(words.enumerated()), id: \.element.id) { index, word in
                        let screenX = (word.position.x * scale) + offset.width + geometry.size.width / 2
                        let screenY = (word.position.y * scale) + offset.height + geometry.size.height / 2
                        
                        DraggableStickerView(
                            word: word,
                            themeColor: Color(hex: location.themeColor),
                            scale: scale,
                            onTap: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    selectedWord = word
                                }
                            },
                            onDragEnd: { translation in
                                // Update sticker position
                                let newPosition = CGPoint(
                                    x: word.position.x + translation.width / scale,
                                    y: word.position.y + translation.height / scale
                                )
                                words[index] = CanvasWord(
                                    predefined: word.predefined,
                                    collected: word.collected,
                                    position: newPosition
                                )
                            }
                        )
                        .position(x: screenX, y: screenY)
                        .zIndex(selectedWord?.id == word.id ? 100 : 0)
                    }
                }
                
                // Zoom indicator
                if scale != 1.0 {
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(Int(scale * 100))%")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.nomiTextLight)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.nomiCardBackground.opacity(0.9))
                                .cornerRadius(8)
                                .padding(8)
                        }
                        Spacer()
                    }
                }
                
                // Inline card overlay - always centered
                if let word = selectedWord {
                    // Dim background
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedWord = nil
                            }
                        }
                    
                    // Card always centered in the canvas
                    InlineWordCard(
                        word: word,
                        language: language,
                        themeColor: Color(hex: location.themeColor),
                        isCollected: collectedWords.contains(word.englishWord.lowercased()),
                        onCollect: {
                            HapticService.shared.collect()
                            onCollectWord(word)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    selectedWord = nil
                                }
                            }
                        },
                        onDismiss: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedWord = nil
                            }
                        }
                    )
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .zIndex(200)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                // Pan gesture
                DragGesture()
                    .onChanged { value in
                        if selectedWord == nil {
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
            .gesture(
                // Pinch to zoom
                MagnificationGesture()
                    .onChanged { value in
                        if selectedWord == nil {
                            let newScale = lastScale * value
                            scale = min(max(newScale, minScale), maxScale)
                        }
                    }
                    .onEnded { _ in
                        lastScale = scale
                    }
            )
            .simultaneousGesture(
                // Double tap to reset
                TapGesture(count: 2)
                    .onEnded {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            scale = 1.0
                            lastScale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        }
                    }
            )
        }
        .clipped()
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State var words: [CanvasWord] = [
            CanvasWord(predefined: PredefinedWord(targetWord: "コーヒー", romanization: "koohii", englishWord: "coffee", exampleSentence: "コーヒーをください。", stickerEmoji: "☕️", stickerAsset: nil), collected: false, position: CGPoint(x: -80, y: -100)),
            CanvasWord(predefined: PredefinedWord(targetWord: "お茶", romanization: "ocha", englishWord: "tea", exampleSentence: "お茶はいかがですか？", stickerEmoji: "🍵", stickerAsset: nil), collected: true, position: CGPoint(x: 80, y: -80)),
            CanvasWord(predefined: PredefinedWord(targetWord: "ケーキ", romanization: "keeki", englishWord: "cake", exampleSentence: "このケーキはおいしいです。", stickerEmoji: "🍰", stickerAsset: nil), collected: false, position: CGPoint(x: 0, y: 50)),
        ]
        
        var body: some View {
            WordCanvasView(
                words: $words,
                collectedWords: ["tea"],
                location: .cafe,
                language: .japanese,
                onCollectWord: { _ in }
            )
        }
    }
    
    return PreviewWrapper()
}
