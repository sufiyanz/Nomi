//
//  AppState.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class AppState {
    var isAuthenticated: Bool = false
    var hasSelectedLanguage: Bool = false
    var currentUser: User?
    var currentJournal: Journal?
    var selectedLanguage: Language?
    
    init() {
        // Check for existing authentication on launch
        checkExistingSession()
    }
    
    func checkExistingSession() {
        if let userId = AuthenticationService.shared.getCurrentUserId() {
            isAuthenticated = true
            // User and journal will be loaded from SwiftData
        }
    }
    
    func signIn(user: User) {
        currentUser = user
        isAuthenticated = true
    }
    
    func signOut() {
        AuthenticationService.shared.signOut()
        currentUser = nil
        currentJournal = nil
        selectedLanguage = nil
        isAuthenticated = false
        hasSelectedLanguage = false
    }
    
    func selectLanguage(_ language: Language, journal: Journal) {
        selectedLanguage = language
        currentJournal = journal
        hasSelectedLanguage = true
    }
    
    func switchJournal(_ journal: Journal, language: Language) {
        currentJournal = journal
        selectedLanguage = language
    }
}
