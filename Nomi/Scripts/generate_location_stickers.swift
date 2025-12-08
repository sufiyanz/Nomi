#!/usr/bin/env swift

//
//  generate_location_stickers.swift
//  Nomi
//
//  Run this script to generate kawaii stickers for all locations using DALL-E 3
//  Usage: swift generate_location_stickers.swift
//
//  Prerequisites:
//  - Set OPENAI_API_KEY environment variable or have .env file in project root
//

import Foundation

// MARK: - Configuration

struct Config {
    static let outputDirectory = "../Nomi/Assets.xcassets/LocationStickers"
    static let imageSize = "1024x1024"
    static let model = "dall-e-3"
    
    static var apiKey: String {
        // Try environment variable first
        if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !key.isEmpty {
            return key
        }
        
        // Try .env file
        let envPath = "../.env"
        if let contents = try? String(contentsOfFile: envPath, encoding: .utf8) {
            for line in contents.components(separatedBy: .newlines) {
                let parts = line.components(separatedBy: "=")
                if parts.count == 2 && parts[0].trimmingCharacters(in: .whitespaces) == "OPENAI_API_KEY" {
                    return parts[1].trimmingCharacters(in: .whitespaces)
                }
            }
        }
        
        fatalError("OPENAI_API_KEY not found. Set it as environment variable or in .env file")
    }
}

// MARK: - Location Sticker Definitions

struct LocationSticker {
    let id: String
    let name: String
    let prompt: String
    let themeColor: String
}

let locationStickers: [LocationSticker] = [
    LocationSticker(
        id: "cafe",
        name: "Cafe",
        prompt: """
        Create a kawaii-style sticker of a cozy Japanese cafe scene. Include a cute steaming coffee cup with a happy face, 
        a small pastry or croissant, and maybe a tiny plant. Style: Japanese kawaii, soft pastel colors (warm browns, cream, pink accents), 
        rounded shapes, adorable expressions, white/transparent background, sticker-like with subtle outline. 
        Simple, clean design suitable as an app icon. No text.
        """,
        themeColor: "#D4A574"
    ),
    LocationSticker(
        id: "restaurant",
        name: "Restaurant",
        prompt: """
        Create a kawaii-style sticker of Japanese restaurant elements. Include a cute bowl of ramen or rice with a happy face, 
        chopsticks, and maybe a small side dish. Style: Japanese kawaii, soft pastel colors (coral red, cream, soft orange), 
        rounded shapes, adorable expressions, white/transparent background, sticker-like with subtle outline.
        Simple, clean design suitable as an app icon. No text.
        """,
        themeColor: "#FF6B6B"
    ),
    LocationSticker(
        id: "store",
        name: "Store",
        prompt: """
        Create a kawaii-style sticker of a cute shopping scene. Include a happy shopping bag with a face, 
        maybe some small items like a coin or price tag with cute expressions. Style: Japanese kawaii, 
        soft pastel colors (teal, mint, cream), rounded shapes, adorable expressions, white/transparent background, 
        sticker-like with subtle outline. Simple, clean design suitable as an app icon. No text.
        """,
        themeColor: "#4ECDC4"
    ),
    LocationSticker(
        id: "station",
        name: "Station",
        prompt: """
        Create a kawaii-style sticker of a cute Japanese train station scene. Include an adorable bullet train (shinkansen) 
        with a happy face, maybe a small ticket or platform sign. Style: Japanese kawaii, soft pastel colors (sky blue, white, soft yellow), 
        rounded shapes, adorable expressions, white/transparent background, sticker-like with subtle outline.
        Simple, clean design suitable as an app icon. No text.
        """,
        themeColor: "#45B7D1"
    ),
    LocationSticker(
        id: "home",
        name: "Home",
        prompt: """
        Create a kawaii-style sticker of a cozy Japanese home scene. Include a cute little house with a happy face, 
        maybe a small window with curtains and a tiny plant or welcome mat. Style: Japanese kawaii, 
        soft pastel colors (sage green, cream, soft pink), rounded shapes, adorable expressions, white/transparent background, 
        sticker-like with subtle outline. Simple, clean design suitable as an app icon. No text.
        """,
        themeColor: "#96CEB4"
    ),
    LocationSticker(
        id: "park",
        name: "Park",
        prompt: """
        Create a kawaii-style sticker of a cute Japanese park scene. Include a happy tree or cherry blossom with a face, 
        maybe a small butterfly or bird, and some grass. Style: Japanese kawaii, soft pastel colors (mint green, pink, cream), 
        rounded shapes, adorable expressions, white/transparent background, sticker-like with subtle outline.
        Simple, clean design suitable as an app icon. No text.
        """,
        themeColor: "#88D8B0"
    ),
    LocationSticker(
        id: "hospital",
        name: "Hospital",
        prompt: """
        Create a kawaii-style sticker of a friendly medical scene. Include a cute first-aid kit or medicine bottle with a happy face, 
        maybe a small bandage or heart symbol. Style: Japanese kawaii, soft pastel colors (light pink, white, soft red), 
        rounded shapes, adorable and comforting expressions, white/transparent background, sticker-like with subtle outline.
        Simple, clean design suitable as an app icon. No text. Make it feel friendly, not scary.
        """,
        themeColor: "#FFB6C1"
    ),
    LocationSticker(
        id: "office",
        name: "Office",
        prompt: """
        Create a kawaii-style sticker of a cute office scene. Include a happy laptop or computer with a face, 
        maybe a small coffee cup and a pencil or notebook. Style: Japanese kawaii, soft pastel colors (plum, lavender, cream), 
        rounded shapes, adorable expressions, white/transparent background, sticker-like with subtle outline.
        Simple, clean design suitable as an app icon. No text.
        """,
        themeColor: "#DDA0DD"
    )
]

// MARK: - API Functions

func generateImage(prompt: String) async throws -> Data {
    let url = URL(string: "https://api.openai.com/v1/images/generations")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(Config.apiKey)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = [
        "model": Config.model,
        "prompt": prompt,
        "n": 1,
        "size": Config.imageSize,
        "quality": "standard",
        "style": "vivid"
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
        throw NSError(domain: "API", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Error: \(errorText)"])
    }
    
    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
          let dataArray = json["data"] as? [[String: Any]],
          let firstImage = dataArray.first,
          let imageURLString = firstImage["url"] as? String,
          let imageURL = URL(string: imageURLString) else {
        throw NSError(domain: "API", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
    }
    
    // Download image
    let (imageData, _) = try await URLSession.shared.data(from: imageURL)
    return imageData
}

func createAssetCatalog(for sticker: LocationSticker, imageData: Data) throws {
    let stickerDir = "\(Config.outputDirectory)/\(sticker.id).imageset"
    
    // Create directory
    try FileManager.default.createDirectory(atPath: stickerDir, withIntermediateDirectories: true)
    
    // Save image
    let imagePath = "\(stickerDir)/\(sticker.id).png"
    try imageData.write(to: URL(fileURLWithPath: imagePath))
    
    // Create Contents.json
    let contents: [String: Any] = [
        "images": [
            [
                "filename": "\(sticker.id).png",
                "idiom": "universal",
                "scale": "1x"
            ],
            [
                "idiom": "universal",
                "scale": "2x"
            ],
            [
                "idiom": "universal",
                "scale": "3x"
            ]
        ],
        "info": [
            "author": "xcode",
            "version": 1
        ]
    ]
    
    let contentsData = try JSONSerialization.data(withJSONObject: contents, options: .prettyPrinted)
    try contentsData.write(to: URL(fileURLWithPath: "\(stickerDir)/Contents.json"))
    
    print("✅ Created asset for \(sticker.name)")
}

// MARK: - Main

func main() async {
    print("🎀 Nomi Location Sticker Generator")
    print("===================================\n")
    
    // Create output directory
    try? FileManager.default.createDirectory(atPath: Config.outputDirectory, withIntermediateDirectories: true)
    
    // Create folder Contents.json
    let folderContents: [String: Any] = [
        "info": [
            "author": "xcode",
            "version": 1
        ]
    ]
    let folderContentsData = try! JSONSerialization.data(withJSONObject: folderContents, options: .prettyPrinted)
    try? folderContentsData.write(to: URL(fileURLWithPath: "\(Config.outputDirectory)/Contents.json"))
    
    for sticker in locationStickers {
        print("🎨 Generating sticker for \(sticker.name)...")
        
        do {
            let imageData = try await generateImage(prompt: sticker.prompt)
            try createAssetCatalog(for: sticker, imageData: imageData)
        } catch {
            print("❌ Failed to generate \(sticker.name): \(error.localizedDescription)")
        }
        
        // Rate limiting - wait between requests
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
    }
    
    print("\n🌸 Done! Generated \(locationStickers.count) location stickers.")
    print("📁 Output: \(Config.outputDirectory)")
}

// Run
Task {
    await main()
    exit(0)
}

RunLoop.main.run()
