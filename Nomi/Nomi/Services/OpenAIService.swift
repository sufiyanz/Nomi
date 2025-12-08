//
//  OpenAIService.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import Foundation
import UIKit

@MainActor
final class OpenAIService: Sendable {
    static let shared = OpenAIService()
    
    private let baseURL = "https://api.openai.com/v1"
    private var apiKey: String {
        // In production, this should be fetched from a secure backend
        // For development, you can set it in Config.swift or environment variable
        Config.openAIAPIKey
    }
    
    private init() {}
    
    // MARK: - Word Generation
    
    func generateWords(
        language: Language,
        location: Location,
        count: Int = 5,
        excludeWords: [String] = []
    ) async throws -> [GeneratedWord] {
        let prompt = buildWordGenerationPrompt(
            language: language,
            location: location,
            count: count,
            excludeWords: excludeWords
        )
        
        let response = try await sendChatCompletion(prompt: prompt)
        return parseWordGenerationResponse(response, language: language)
    }
    
    private func buildWordGenerationPrompt(
        language: Language,
        location: Location,
        count: Int,
        excludeWords: [String]
    ) -> String {
        var prompt = """
        Generate exactly \(count) vocabulary words for someone learning \(language.name).
        Context: \(location.promptContext)
        Difficulty: Beginner to intermediate level
        
        """
        
        if !excludeWords.isEmpty {
            prompt += "Do NOT include these words (already learned): \(excludeWords.joined(separator: ", "))\n\n"
        }
        
        prompt += """
        Respond ONLY with a valid JSON object in this exact format:
        {
            "words": [
                {
                    "target_word": "word in \(language.name)",
                    \(language.hasRomanization ? "\"romanization\": \"romanized pronunciation\"," : "\"romanization\": null,")
                    "english_word": "English translation",
                    "example_sentence": "A simple example sentence in \(language.name)"
                }
            ]
        }
        
        Requirements:
        - Each word should be a single word or very short phrase
        - Words should be practical and commonly used in the \(location.name.lowercased()) context
        - Example sentences should be simple and beginner-friendly
        \(language.hasRomanization ? "- Include accurate romanization" : "")
        """
        
        return prompt
    }
    
    private func parseWordGenerationResponse(_ response: String, language: Language) -> [GeneratedWord] {
        // Try to extract JSON from the response
        guard let jsonData = extractJSON(from: response) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let wordResponse = try decoder.decode(WordGenerationResponse.self, from: jsonData)
            
            return wordResponse.words.map { wordData in
                GeneratedWord(
                    targetWord: wordData.targetWord,
                    romanization: wordData.romanization,
                    englishWord: wordData.englishWord,
                    exampleSentence: wordData.exampleSentence
                )
            }
        } catch {
            print("Failed to parse word generation response: \(error)")
            return []
        }
    }
    
    // MARK: - Image Generation
    
    func generateStickerImage(for word: String, englishMeaning: String) async throws -> Data {
        let prompt = """
        Create a kawaii-style sticker illustration representing "\(englishMeaning)".
        Style: Japanese kawaii, soft pastel colors (pink, mint, peach, lavender), 
        cute rounded shapes, simple design, white background, sticker-like appearance 
        with subtle outline. The illustration should be adorable and child-friendly.
        Do not include any text in the image.
        """
        
        let requestBody: [String: Any] = [
            "model": "dall-e-3",
            "prompt": prompt,
            "n": 1,
            "size": "1024x1024",
            "quality": "standard",
            "style": "vivid"
        ]
        
        let url = URL(string: "\(baseURL)/images/generations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OpenAIError.imageGenerationFailed
        }
        
        // Parse response to get image URL
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataArray = json["data"] as? [[String: Any]],
              let firstImage = dataArray.first,
              let imageURLString = firstImage["url"] as? String,
              let imageURL = URL(string: imageURLString) else {
            throw OpenAIError.invalidImageResponse
        }
        
        // Download the image
        let (imageData, _) = try await URLSession.shared.data(from: imageURL)
        
        // Resize image for storage efficiency
        if let uiImage = UIImage(data: imageData),
           let resizedImage = uiImage.resized(to: CGSize(width: 512, height: 512)),
           let pngData = resizedImage.pngData() {
            return pngData
        }
        
        return imageData
    }
    
    // MARK: - Chat Completion
    
    private func sendChatCompletion(prompt: String) async throws -> String {
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful language learning assistant. Always respond with valid JSON when asked."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 1500
        ]
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.networkError
        }
        
        guard httpResponse.statusCode == 200 else {
            throw OpenAIError.apiError(statusCode: httpResponse.statusCode)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenAIError.invalidResponse
        }
        
        return content
    }
    
    // MARK: - Helpers
    
    private func extractJSON(from string: String) -> Data? {
        // Try to find JSON in the response
        if let startIndex = string.firstIndex(of: "{"),
           let endIndex = string.lastIndex(of: "}") {
            let jsonString = String(string[startIndex...endIndex])
            return jsonString.data(using: .utf8)
        }
        return string.data(using: .utf8)
    }
}

// MARK: - Errors

enum OpenAIError: Error, LocalizedError {
    case networkError
    case apiError(statusCode: Int)
    case invalidResponse
    case imageGenerationFailed
    case invalidImageResponse
    case rateLimited
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error. Please check your connection."
        case .apiError(let statusCode):
            return "API error (code: \(statusCode)). Please try again."
        case .invalidResponse:
            return "Invalid response from AI service."
        case .imageGenerationFailed:
            return "Failed to generate sticker image."
        case .invalidImageResponse:
            return "Invalid image response."
        case .rateLimited:
            return "Too many requests. Please wait a moment."
        }
    }
}

// MARK: - UIImage Extension

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
