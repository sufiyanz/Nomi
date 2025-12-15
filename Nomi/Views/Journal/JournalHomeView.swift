//
//  JournalHomeView.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import SwiftUI
import SwiftData

struct JournalHomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    
    @State private var showLanguageSwitcher = false
    @State private var showSettings = false
    @State private var selectedLocation: Location?
    
    private let columns = [
        GridItem(.flexible(), spacing: NomiSpacing.medium),
        GridItem(.flexible(), spacing: NomiSpacing.medium)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.nomiBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: NomiSpacing.large) {
                        // Welcome header
                        welcomeHeader
                            .padding(.top)
                        
                        // Location grid
                        LazyVGrid(columns: columns, spacing: NomiSpacing.medium) {
                            ForEach(Location.allCases.sorted(by: { $0.sortOrder < $1.sortOrder })) { location in
                                LocationCard(
                                    location: location,
                                    wordCount: wordCount(for: location)
                                ) {
                                    selectedLocation = location
                                }
                                .popIn(delay: Double(location.sortOrder) * 0.05)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Stats footer
                        statsFooter
                            .padding(.top, NomiSpacing.medium)
                        
                        Spacer(minLength: NomiSpacing.huge)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    languageSwitcherButton
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.nomiTextLight)
                    }
                }
            }
            .sheet(isPresented: $showLanguageSwitcher) {
                LanguageSwitcherView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .navigationDestination(item: $selectedLocation) { location in
                LocationJournalView(location: location)
            }
        }
    }
    
    // MARK: - Welcome Header
    
    private var welcomeHeader: some View {
        VStack(spacing: NomiSpacing.small) {
            Text(greeting)
                .font(.nomiBody())
                .foregroundColor(.nomiTextLight)
            
            Text("Your \(appState.selectedLanguage?.name ?? "Language") Journal")
                .font(.nomiTitle())
                .foregroundColor(.nomiTextDark)
        }
        .popIn()
    }
    
    // MARK: - Language Switcher Button
    
    private var languageSwitcherButton: some View {
        Button {
            HapticService.shared.tap()
            showLanguageSwitcher = true
        } label: {
            HStack(spacing: NomiSpacing.small) {
                Text(appState.selectedLanguage?.flagEmoji ?? "🌍")
                    .font(.system(size: 20))
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.nomiTextLight)
            }
            .padding(.horizontal, NomiSpacing.small)
            .padding(.vertical, NomiSpacing.tiny)
            .background(Color.nomiCardBackground)
            .cornerRadius(NomiRadius.medium)
            .nomiShadow(radius: 4, y: 2)
        }
        .bouncePress(scale: 0.97)
    }
    
    // MARK: - Stats Footer
    
    private var statsFooter: some View {
        VStack(spacing: NomiSpacing.small) {
            let total = totalWordCount
            
            HStack(spacing: NomiSpacing.large) {
                StatBubble(value: "\(total)", label: "Words")
                StatBubble(value: "\(masteredCount)", label: "Mastered")
                StatBubble(value: "\(locationsWithWords)", label: "Locations")
            }
            
            if total == 0 {
                Text("Tap a location to start collecting words!")
                    .font(.nomiCaption())
                    .foregroundColor(.nomiTextLight)
                    .padding(.top, NomiSpacing.small)
            }
        }
        .padding()
        .background(Color.nomiCardBackground.opacity(0.5))
        .cornerRadius(NomiRadius.large)
        .padding(.horizontal)
    }
    
    // MARK: - Helpers
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning! ☀️"
        case 12..<17: return "Good afternoon! 🌤"
        default: return "Good evening! 🌙"
        }
    }
    
    private func wordCount(for location: Location) -> Int {
        appState.currentJournal?.wordCount(for: location) ?? 0
    }
    
    private var totalWordCount: Int {
        appState.currentJournal?.totalWordCount ?? 0
    }
    
    private var masteredCount: Int {
        appState.currentJournal?.stickerWords.filter { $0.isMastered }.count ?? 0
    }
    
    private var locationsWithWords: Int {
        guard let journal = appState.currentJournal else { return 0 }
        let locations = Set(journal.stickerWords.map { $0.locationId })
        return locations.count
    }
}

// MARK: - Stat Bubble

struct StatBubble: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.nomiHeadline())
                .foregroundColor(.nomiPink)
            
            Text(label)
                .font(.nomiCaption())
                .foregroundColor(.nomiTextLight)
        }
    }
}

#Preview {
    JournalHomeView()
        .environment(AppState())
        .modelContainer(for: [User.self, Journal.self, StickerWord.self], inMemory: true)
}
