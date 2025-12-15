import SwiftUI

// MARK: - Content View (Router)

struct ContentView: View {
    
    @Environment(AppState.self) private var appState
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
        .animation(Theme.Animation.standard, value: appState.isAuthenticated)
        .onReceive(appState.authService.$isAuthenticated) { isAuthenticated in
            appState.isAuthenticated = isAuthenticated
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    
    @Environment(AppState.self) private var appState
    
    var body: some View {
        @Bindable var state = appState
        
        NavigationStack {
            SpacesHomeView()
                .navigationDestination(item: $state.selectedSpace) { space in
                    SpaceDetailView(location: space)
                }
        }
        .sheet(isPresented: $state.showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $state.showLanguagePicker) {
            LanguageSwitcherView()
                .presentationDetents([.medium])
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(AppState())
}
