//
//  LanguagePickerView.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import SwiftUI
import SwiftData

struct LanguagePickerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let isInitialSelection: Bool
    
    @State private var selectedLanguage: Language?
    @State private var isCreatingJournal = false
    @Query private var journals: [Journal]
    
    private let columns = [
        GridItem(.flexible(), spacing: NomiSpacing.medium),
        GridItem(.flexible(), spacing: NomiSpacing.medium)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: NomiSpacing.small) {
                    Text(isInitialSelection ? "Choose a language" : "Add a language")
                        .font(.nomiTitle())
                        .foregroundColor(.nomiTextDark)
                    
                    Text(isInitialSelection ? "Which language would you like to learn?" : "Start a new journal")
                        .font(.nomiBody())
                        .foregroundColor(.nomiTextLight)
                }
                .padding(.top, NomiSpacing.medium)
                .padding(.bottom, NomiSpacing.small)
                
                // Scrollable language grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: NomiSpacing.medium) {
                        ForEach(availableLanguages, id: \.self) { language in
                            LanguageCard(
                                language: language,
                                isSelected: selectedLanguage == language,
                                isAlreadyAdded: hasJournalForLanguage(language)
                            ) {
                                if !hasJournalForLanguage(language) {
                                    HapticService.shared.selectionChanged()
                                    withAnimation(.nomiBounce) {
                                        selectedLanguage = language
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                
                // Continue button at bottom
                KawaiiButton(
                    title: "Start Learning",
                    icon: "✨",
                    isLoading: isCreatingJournal
                ) {
                    createJournalAndContinue()
                }
                .disabled(selectedLanguage == nil)
                .opacity(selectedLanguage == nil ? 0.5 : 1)
                .padding(.horizontal, NomiSpacing.large)
                .padding(.vertical, NomiSpacing.medium)
            }
            .background(LinearGradient.nomiBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isInitialSelection {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.nomiPink)
                    }
                }
            }
        }
    }
    
    private var availableLanguages: [Language] {
        Language.allCases.sorted { $0.name < $1.name }
    }
    
    private func hasJournalForLanguage(_ language: Language) -> Bool {
        guard let userId = appState.currentUser?.id else { return false }
        return journals.contains { $0.userId == userId && $0.languageCode == language.code }
    }
    
    private func createJournalAndContinue() {
        guard let language = selectedLanguage,
              let user = appState.currentUser else { return }
        
        isCreatingJournal = true
        HapticService.shared.success()
        
        // Create new journal
        let journal = Journal(
            userId: user.id,
            languageCode: language.code
        )
        journal.user = user
        
        modelContext.insert(journal)
        
        do {
            try modelContext.save()
            appState.selectLanguage(language, journal: journal)
            
            if !isInitialSelection {
                dismiss()
            }
        } catch {
            print("Failed to create journal: \(error)")
        }
        
        isCreatingJournal = false
    }
}

// MARK: - Language Card

struct LanguageCard: View {
    let language: Language
    let isSelected: Bool
    let isAlreadyAdded: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: NomiSpacing.small) {
                Text(language.flagEmoji)
                    .font(.system(size: 44))
                
                VStack(spacing: 2) {
                    Text(language.name)
                        .font(.nomiSubheadline())
                        .foregroundColor(isAlreadyAdded ? .nomiTextLight : .nomiTextDark)
                    
                    Text(language.nativeName)
                        .font(.nomiCaption())
                        .foregroundColor(.nomiTextLight)
                }
                
                if isAlreadyAdded {
                    Text("Added")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.nomiMint)
                        .cornerRadius(10)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, NomiSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: NomiRadius.large)
                    .fill(isSelected ? Color.nomiPink.opacity(0.15) : Color.nomiCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: NomiRadius.large)
                    .stroke(isSelected ? Color.nomiPink : Color.clear, lineWidth: 3)
            )
            .nomiShadow()
        }
        .buttonStyle(BouncePressStyle())
        .disabled(isAlreadyAdded)
        .opacity(isAlreadyAdded ? 0.6 : 1)
    }
}

#Preview {
    LanguagePickerView(isInitialSelection: true)
        .environment(AppState())
        .modelContainer(for: [User.self, Journal.self, StickerWord.self], inMemory: true)
}
