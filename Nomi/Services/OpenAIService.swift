import Foundation

// MARK: - OpenAI Service

@MainActor
class OpenAIService: ObservableObject {
    
    static let shared = OpenAIService()
    
    @Published var isLoading = false
    @Published var error: Error?
    
    private let apiKey: String
    private let session: URLSession
    
    private init() {
        self.apiKey = Config.openAIAPIKey
        self.session = URLSession.shared
    }
    
    // MARK: - Public Methods
    
    /// Generates translation data for a word
    func generateTranslation(
        englishWord: String,
        targetLanguage: Language,
        context: Location
    ) async throws -> GeneratedWord {
        isLoading = true
        defer { isLoading = false }
        
        let prompt = buildTranslationPrompt(
            word: englishWord,
            language: targetLanguage,
            context: context
        )
        
        let response = try await makeRequest(prompt: prompt)
        
        guard let translationData = parseTranslationResponse(response) else {
            throw OpenAIError.parsingFailed
        }
        
        return GeneratedWord(
            wordKey: englishWord.lowercased().replacingOccurrences(of: " ", with: "_"),
            englishWord: englishWord,
            languageCode: targetLanguage.rawValue,
            translatedWord: translationData.translatedWord,
            romanization: translationData.romanization,
            exampleSentence: translationData.exampleSentence,
            exampleRomanization: translationData.exampleRomanization,
            exampleTranslation: translationData.exampleTranslation
        )
    }
    
    /// Batch generates translations for multiple words
    func generateTranslations(
        words: [String],
        targetLanguage: Language,
        context: Location
    ) async throws -> [GeneratedWord] {
        var results: [GeneratedWord] = []
        
        for word in words {
            do {
                let translation = try await generateTranslation(
                    englishWord: word,
                    targetLanguage: targetLanguage,
                    context: context
                )
                results.append(translation)
            } catch {
                print("Failed to translate '\(word)': \(error)")
                // Continue with other words
            }
        }
        
        return results
    }
    
    // MARK: - Private Methods
    
    private func buildTranslationPrompt(word: String, language: Language, context: Location) -> String {
        let needsRomanization = language.usesRomanization
        
        return """
        Translate the word "\(word)" to \(language.displayName) for use in a language learning app.
        
        Context: This word is being learned in the context of a \(context.displayName.lowercased()).
        
        Provide a JSON response with:
        1. "translatedWord": The word in \(language.displayName)
        \(needsRomanization ? "2. \"romanization\": The romanized/phonetic version" : "2. \"romanization\": null")
        3. "exampleSentence": A simple, practical example sentence using this word in \(language.displayName)
        \(needsRomanization ? "4. \"exampleRomanization\": The romanized version of the example sentence" : "4. \"exampleRomanization\": null")
        5. "exampleTranslation": The English translation of the example sentence
        
        The example sentence should be:
        - Simple and practical (A1-A2 level)
        - Related to the \(context.displayName.lowercased()) context when possible
        - Natural and commonly used
        
        Respond with ONLY valid JSON, no markdown or explanation.
        """
    }
    
    private func makeRequest(prompt: String) async throws -> String {
        var request = URLRequest(url: Config.URLs.openAIAPI)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful language translation assistant. Always respond with valid JSON only."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": 500
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw OpenAIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenAIError.parsingFailed
        }
        
        return content
    }
    
    private func parseTranslationResponse(_ response: String) -> OpenAITranslationResponse? {
        // Clean up the response (remove markdown code blocks if present)
        var cleanedResponse = response
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanedResponse.data(using: .utf8) else {
            return nil
        }
        
        do {
            let decoded = try JSONDecoder().decode(OpenAITranslationResponse.self, from: data)
            return decoded
        } catch {
            print("Failed to parse OpenAI response: \(error)")
            print("Response was: \(cleanedResponse)")
            return nil
        }
    }
}

// MARK: - OpenAI Errors

enum OpenAIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case parsingFailed
    case rateLimited
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from OpenAI"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .parsingFailed:
            return "Failed to parse response"
        case .rateLimited:
            return "Rate limited. Please try again later."
        }
    }
}
