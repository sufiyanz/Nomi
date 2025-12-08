//
//  ContentView.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @Query private var journals: [Journal]
    
    var body: some View {
        Group {
            if !appState.isAuthenticated {
                WelcomeView()
            } else if !appState.hasSelectedLanguage {
                LanguagePickerView(isInitialSelection: true)
                    .onAppear {
                        loadUserData()
                    }
            } else {
                JournalHomeView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: appState.hasSelectedLanguage)
    }
    
    private func loadUserData() {
        // Load existing user if authenticated
        if let userId = AuthenticationService.shared.getCurrentUserId(),
           let user = users.first(where: { $0.appleUserIdentifier == userId }) {
            appState.currentUser = user
            
            // Check if user has any journals
            let userJournals = journals.filter { $0.userId == user.id }
            if let firstJournal = userJournals.first,
               let language = Language.allCases.first(where: { $0.code == firstJournal.languageCode }) {
                appState.selectLanguage(language, journal: firstJournal)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .modelContainer(for: [User.self, Journal.self, StickerWord.self], inMemory: true)
}
