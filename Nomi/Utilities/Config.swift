//
//  Config.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import Foundation

enum Config {
    // MARK: - API Keys
    // In production, these should be fetched from a secure backend service
    // Never commit actual API keys to source control
    
    static var openAIAPIKey: String {
        // Try to get from environment variable first (for development)
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
           !envKey.isEmpty {
            return envKey
        }
        
        // Try to get from Secrets.plist (not committed to git)
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["OPENAI_API_KEY"] as? String,
           !key.isEmpty {
            return key
        }
        
        // Try to read from .env file in project directory (development only)
        #if DEBUG
        if let key = loadFromEnvFile() {
            return key
        }
        #endif
        
        // Placeholder - replace with your API key for development
        // TODO: Replace with actual API key or backend proxy
        return "YOUR_OPENAI_API_KEY_HERE"
    }
    
    #if DEBUG
    private static func loadFromEnvFile() -> String? {
        // Get the path to the .env file relative to the app bundle
        // During development, we can hardcode the project path
        let possiblePaths = [
            "/Users/suffsyed/Personal Projects/Nomi/.env",
            NSHomeDirectory() + "/Personal Projects/Nomi/.env"
        ]
        
        for envPath in possiblePaths {
            if let contents = try? String(contentsOfFile: envPath, encoding: .utf8) {
                for line in contents.components(separatedBy: .newlines) {
                    let parts = line.components(separatedBy: "=")
                    if parts.count == 2 && parts[0].trimmingCharacters(in: .whitespaces) == "OPENAI_API_KEY" {
                        let key = parts[1].trimmingCharacters(in: .whitespaces)
                        if !key.isEmpty && key != "YOUR_OPENAI_API_KEY_HERE" {
                            return key
                        }
                    }
                }
            }
        }
        return nil
    }
    #endif
    
    // MARK: - App Configuration
    
    static let appName = "Nomi"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    // MARK: - Feature Flags
    
    static let enableImageGeneration = true
    static let maxWordsPerSession = 5
    static let minWordsForRevision = 3
    
    // MARK: - URLs
    
    static let privacyPolicyURL = URL(string: "https://example.com/privacy")!
    static let termsOfServiceURL = URL(string: "https://example.com/terms")!
    
    // MARK: - Default Settings
    
    static let defaultReminderHour = 9
    static let defaultReminderMinute = 0
}
