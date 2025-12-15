import Foundation
import SwiftUI
import SwiftData

// MARK: - App State

@MainActor
@Observable
class AppState {
    
    // MARK: - Navigation
    
    var isAuthenticated = false
    var showOnboarding = false
    var selectedSpace: Location?
    var selectedWord: StickerWord?
    var showSettings = false
    var showLanguagePicker = false
    
    // MARK: - User Preferences
    
    var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
        }
    }
    
    var streakCount: Int = 0
    
    // MARK: - Services
    
    let authService = AuthenticationService.shared
    let audioService = AudioService.shared
    let openAIService = OpenAIService.shared
    let notificationService = NotificationService.shared
    let hapticService = HapticService.shared
    
    // MARK: - Initialization
    
    init() {
        // Load saved language preference
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            self.currentLanguage = Config.Defaults.defaultLanguage
        }
        
        // Sync with auth service
        self.isAuthenticated = authService.isAuthenticated
    }
    
    // MARK: - Methods
    
    func signIn() async {
        authService.signInWithApple()
    }
    
    func signOut() {
        authService.signOut()
        isAuthenticated = false
    }
    
    func selectLanguage(_ language: Language) {
        currentLanguage = language
        showLanguagePicker = false
        hapticService.selectionChanged()
    }
    
    func openSpace(_ space: Location) {
        selectedSpace = space
        hapticService.lightImpact()
    }
    
    func closeSpace() {
        selectedSpace = nil
    }
    
    func selectWord(_ word: StickerWord) {
        selectedWord = word
        hapticService.mediumImpact()
    }
    
    func closeWord() {
        selectedWord = nil
    }
    
    func collectWord(_ word: StickerWord) {
        word.collect()
        hapticService.success()
        // TODO: Update streak
    }
}
