//
//  LanguageSwitcherView.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import SwiftUI
import SwiftData

struct LanguageSwitcherView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    @Query private var journals: [Journal]
    @State private var showLanguagePicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.nomiBackground
                    .ignoresSafeArea()
                
                VStack(spacing: NomiSpacing.medium) {
                    // Current journals
                    ScrollView {
                        VStack(spacing: NomiSpacing.small) {
                            ForEach(userJournals, id: \.id) { journal in
                                if let language = journal.language {
                                    JournalRow(
                                        language: language,
                                        wordCount: journal.totalWordCount,
                                        isSelected: appState.currentJournal?.id == journal.id
                                    ) {
                                        switchToJournal(journal, language: language)
                                    }
                                    .popIn(delay: Double(userJournals.firstIndex(where: { $0.id == journal.id }) ?? 0) * 0.05)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Add new language button
                    Button {
                        showLanguagePicker = true
                    } label: {
                        HStack(spacing: NomiSpacing.small) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                            
                            Text("Add New Language")
                                .font(.nomiSubheadline())
                        }
                        .foregroundColor(.nomiPink)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.nomiPink.opacity(0.1))
                        .cornerRadius(NomiRadius.medium)
                    }
                    .bouncePress()
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Your Journals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.nomiPink)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerView(isInitialSelection: false)
            }
        }
    }
    
    private var userJournals: [Journal] {
        guard let userId = appState.currentUser?.id else { return [] }
        return journals
            .filter { $0.userId == userId }
            .sorted { $0.lastOpenedAt > $1.lastOpenedAt }
    }
    
    private func switchToJournal(_ journal: Journal, language: Language) {
        HapticService.shared.selectionChanged()
        journal.updateLastOpened()
        appState.switchJournal(journal, language: language)
        dismiss()
    }
}

// MARK: - Journal Row

struct JournalRow: View {
    let language: Language
    let wordCount: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: NomiSpacing.medium) {
                // Flag
                Text(language.flagEmoji)
                    .font(.system(size: 36))
                
                // Language info
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.name)
                        .font(.nomiSubheadline())
                        .foregroundColor(.nomiTextDark)
                    
                    Text("\(wordCount) words collected")
                        .font(.nomiCaption())
                        .foregroundColor(.nomiTextLight)
                }
                
                Spacer()
                
                // Selected indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.nomiPink)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: NomiRadius.medium)
                    .fill(isSelected ? Color.nomiPink.opacity(0.1) : Color.nomiCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: NomiRadius.medium)
                    .stroke(isSelected ? Color.nomiPink : Color.gray.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
        }
        .bouncePress()
    }
}

#Preview {
    LanguageSwitcherView()
        .environment(AppState())
        .modelContainer(for: [User.self, Journal.self, StickerWord.self], inMemory: true)
}
