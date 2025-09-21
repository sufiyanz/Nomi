//
//  ContentView.swift
//  Wee
//
//  Created by Suff Syed on 9/21/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            TabView {
                DashboardView()
                    .tabItem { Label("Dashboard", systemImage: "rectangle.grid.2x2") }
                CalendarView()
                    .tabItem { Label("Calendar", systemImage: "calendar") }
                ChoresView()
                    .tabItem { Label("Chores", systemImage: "checkmark.circle") }
                AdhanView()
                    .tabItem { Label("Adhan", systemImage: "speaker.wave.2") }
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
