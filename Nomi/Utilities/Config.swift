import Foundation

// MARK: - Config

enum Config {
    
    // MARK: - API Keys
    
    static var openAIAPIKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["OPENAI_API_KEY"] as? String else {
            fatalError("Missing Secrets.plist or OPENAI_API_KEY. Copy Secrets.example.plist to Secrets.plist and add your API key.")
        }
        return key
    }
    
    // MARK: - URLs
    
    enum URLs {
        static let privacyPolicy = URL(string: "https://nomi.app/privacy")!
        static let termsOfService = URL(string: "https://nomi.app/terms")!
        static let openAIAPI = URL(string: "https://api.openai.com/v1/chat/completions")!
    }
    
    // MARK: - App Constants
    
    enum App {
        static let name = "Nomi"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - Feature Flags
    
    enum Features {
        static let enableHaptics = true
        static let enableTTS = true
        static let enableNotifications = true
    }
    
    // MARK: - Defaults
    
    enum Defaults {
        static let defaultLanguage = Language.japanese
        static let defaultReminderHour = 9
        static let defaultReminderMinute = 0
    }
    
    // MARK: - Limits
    
    enum Limits {
        static let maxWordsPerSpace = 25
        static let maxReviewsPerSession = 20
    }
}
