//
//  NomiApp.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import SwiftUI
import SwiftData

@main
struct NomiApp: App {
    let modelContainer: ModelContainer
    @State private var appState = AppState()
    
    init() {
        do {
            let schema = Schema([
                User.self,
                Journal.self,
                StickerWord.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
    }
}
