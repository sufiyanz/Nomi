//
//  PreviewHelpers.swift
//  Nomi
//
//  Helpers for Xcode Previews
//

import SwiftUI
import SwiftData

// MARK: - Preview Container
/// Use this to wrap previews that need SwiftData and AppState
struct PreviewContainer<Content: View>: View {
    let content: Content
    @State private var appState = AppState()
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .environment(appState)
            .modelContainer(previewContainer)
    }
}

// MARK: - Preview Model Container
@MainActor
let previewContainer: ModelContainer = {
    do {
        let schema = Schema([User.self, Journal.self, StickerWord.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        
        // Add sample data
        let user = User(appleUserIdentifier: "preview-user", email: "preview@example.com")
        container.mainContext.insert(user)
        
        let journal = Journal(userId: user.id, languageCode: "ja")
        journal.user = user
        container.mainContext.insert(journal)
        
        // Add sample stickers
        let sampleWords = [
            ("コーヒー", "koohii", "coffee", Location.cafe),
            ("ラテ", "rate", "latte", Location.cafe),
            ("ケーキ", "keeki", "cake", Location.cafe),
            ("ラーメン", "raamen", "ramen", Location.restaurant),
            ("寿司", "sushi", "sushi", Location.restaurant),
        ]
        
        for (target, roman, english, location) in sampleWords {
            let sticker = StickerWord(
                journalId: journal.id,
                locationId: location.id,
                targetWord: target,
                romanization: roman,
                englishWord: english,
                exampleSentence: "これは\(target)です。"
            )
            sticker.journal = journal
            container.mainContext.insert(sticker)
        }
        
        return container
    } catch {
        fatalError("Failed to create preview container: \(error)")
    }
}()

// MARK: - Preview App State
extension AppState {
    static var preview: AppState {
        let state = AppState()
        state.isAuthenticated = true
        state.hasSelectedLanguage = true
        state.selectedLanguage = .japanese
        return state
    }
    
    static var previewUnauthenticated: AppState {
        AppState()
    }
    
    static var previewNoLanguage: AppState {
        let state = AppState()
        state.isAuthenticated = true
        state.hasSelectedLanguage = false
        return state
    }
}

// MARK: - Sample Generated Words (for Learn flow preview)
extension GeneratedWord {
    static var samples: [GeneratedWord] {
        [
            GeneratedWord(
                targetWord: "水",
                romanization: "mizu",
                englishWord: "water",
                exampleSentence: "水をください。"
            ),
            GeneratedWord(
                targetWord: "お茶",
                romanization: "ocha",
                englishWord: "tea",
                exampleSentence: "お茶を飲みます。"
            ),
            GeneratedWord(
                targetWord: "砂糖",
                romanization: "satou",
                englishWord: "sugar",
                exampleSentence: "砂糖を入れますか？"
            ),
        ]
    }
}

// MARK: - Preview Wrappers for Each Screen

#Preview("Welcome") {
    WelcomeView()
        .environment(AppState.previewUnauthenticated)
        .modelContainer(previewContainer)
}

#Preview("Language Picker") {
    LanguagePickerView(isInitialSelection: true)
        .environment(AppState.previewNoLanguage)
        .modelContainer(previewContainer)
}

#Preview("Journal Home") {
    PreviewContainer {
        JournalHomeView()
    }
}

#Preview("Location Journal - Cafe") {
    NavigationStack {
        PreviewContainer {
            LocationJournalView(location: .cafe)
        }
    }
}

#Preview("Settings") {
    PreviewContainer {
        SettingsView()
    }
}

#Preview("Language Switcher") {
    PreviewContainer {
        LanguageSwitcherView()
    }
}

// MARK: - Component Previews

#Preview("Kawaii Buttons") {
    VStack(spacing: 20) {
        KawaiiButton(title: "Primary", icon: "✨", style: .primary) {}
        KawaiiButton(title: "Secondary", icon: "🌸", style: .secondary) {}
        KawaiiButton(title: "Outline", style: .outline) {}
        KawaiiButton(title: "Loading...", isLoading: true) {}
    }
    .padding()
}

#Preview("Location Cards") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        ForEach(Location.allCases.prefix(4)) { location in
            LocationCard(location: location, wordCount: Int.random(in: 0...20)) {}
        }
    }
    .padding()
}

#Preview("Language Badges") {
    VStack(spacing: 12) {
        LanguageBadge(language: .japanese, isSelected: true, showWordCount: true, wordCount: 45)
        LanguageBadge(language: .korean, isSelected: false, showWordCount: true, wordCount: 23)
        LanguageBadge(language: .spanish, isSelected: false, showWordCount: true, wordCount: 0)
    }
    .padding()
}

#Preview("Mastery Indicators") {
    VStack(spacing: 16) {
        ForEach(1...5, id: \.self) { level in
            HStack {
                Text("Level \(level)")
                Spacer()
                MasteryIndicator(level: level)
            }
        }
    }
    .padding()
}

#Preview("Empty State") {
    EmptyStateView(
        icon: "☕",
        title: "No stickers yet!",
        message: "Start learning to collect kawaii stickers.",
        actionTitle: "Start Learning"
    ) {}
}

#Preview("Floating Action Buttons") {
    ZStack {
        Color.nomiBackground.ignoresSafeArea()
        
        VStack {
            Spacer()
            HStack(spacing: 16) {
                FloatingActionButton(icon: "📖", title: "Revise", color: .nomiMint) {}
                FloatingActionButton(icon: "✨", title: "Learn New", color: .nomiPink) {}
            }
        }
        .padding()
    }
}

#Preview("Color Palette") {
    ScrollView {
        VStack(spacing: 16) {
            Group {
                colorSwatch("Pink", Color.nomiPink)
                colorSwatch("Cream", Color.nomiCream)
                colorSwatch("Mint", Color.nomiMint)
                colorSwatch("Lavender", Color.nomiLavender)
                colorSwatch("Peach", Color.nomiPeach)
                colorSwatch("Sky", Color.nomiSky)
            }
            
            Divider()
            
            Group {
                colorSwatch("Text", Color.nomiText)
                colorSwatch("Text Light", Color.nomiTextLight)
                colorSwatch("Text Dark", Color.nomiTextDark)
            }
            
            Divider()
            
            Group {
                colorSwatch("Background", Color.nomiBackground)
                colorSwatch("Paper", Color.nomiPaper)
                colorSwatch("Card", Color.nomiCardBackground)
            }
        }
        .padding()
    }
}

private func colorSwatch(_ name: String, _ color: Color) -> some View {
    HStack {
        RoundedRectangle(cornerRadius: 8)
            .fill(color)
            .frame(width: 60, height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        Text(name)
            .font(.nomiBody())
        Spacer()
    }
}
