//
//  WelcomeView.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import SwiftUI
import AuthenticationServices
import SwiftData

struct WelcomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    
    @State private var isAnimating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient.nomiBackground
                .ignoresSafeArea()
            
            VStack(spacing: NomiSpacing.extraLarge) {
                Spacer()
                
                // Logo and branding
                VStack(spacing: NomiSpacing.medium) {
                    // Animated logo
                    ZStack {
                        Circle()
                            .fill(Color.nomiPink.opacity(0.2))
                            .frame(width: 140, height: 140)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                        
                        Circle()
                            .fill(Color.nomiPink.opacity(0.3))
                            .frame(width: 110, height: 110)
                        
                        Text("📔")
                            .font(.system(size: 60))
                            .floating(amplitude: 8, duration: 2.5)
                    }
                    .animation(
                        .easeInOut(duration: 2).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                    
                    // App name
                    VStack(spacing: NomiSpacing.tiny) {
                        Text("Nomi")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.nomiTextDark)
                        
                        Text("のみ")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.nomiTextLight)
                    }
                    
                    // Tagline
                    Text("Collect words, learn languages")
                        .font(.nomiBody())
                        .foregroundColor(.nomiTextLight)
                        .padding(.top, NomiSpacing.small)
                }
                .popIn()
                
                Spacer()
                
                // Decorative stickers
                HStack(spacing: NomiSpacing.large) {
                    Text("🌸")
                        .font(.system(size: 30))
                        .floating(amplitude: 6, duration: 2.2)
                        .popIn(delay: 0.2)
                    
                    Text("✨")
                        .font(.system(size: 24))
                        .floating(amplitude: 4, duration: 1.8)
                        .popIn(delay: 0.3)
                    
                    Text("📚")
                        .font(.system(size: 30))
                        .floating(amplitude: 5, duration: 2.0)
                        .popIn(delay: 0.4)
                    
                    Text("🎀")
                        .font(.system(size: 24))
                        .floating(amplitude: 6, duration: 2.3)
                        .popIn(delay: 0.5)
                }
                
                Spacer()
                
                // Sign in button
                VStack(spacing: NomiSpacing.medium) {
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: configureRequest,
                        onCompletion: handleCompletion
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 54)
                    .cornerRadius(NomiRadius.large)
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.6 : 1)
                    
                    #if DEBUG
                    // Test user bypass - only in DEBUG builds
                    Button(action: signInAsTestUser) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                            Text("Continue as Test User")
                        }
                        .font(.nomiBody())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.nomiPink)
                        .cornerRadius(NomiRadius.large)
                    }
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.6 : 1)
                    #endif
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .nomiPink))
                    }
                    
                    Text("Your data stays on your device")
                        .font(.nomiCaption())
                        .foregroundColor(.nomiTextLight)
                }
                .padding(.horizontal, NomiSpacing.extraLarge)
                .slideIn(from: .bottom, delay: 0.6)
                
                Spacer()
                    .frame(height: NomiSpacing.huge)
            }
            .padding()
        }
        .onAppear {
            isAnimating = true
        }
        .alert("Sign In Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func configureRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.email]
    }
    
    #if DEBUG
    private func signInAsTestUser() {
        isLoading = true
        
        let authResult = AuthenticationService.shared.signInAsTestUser()
        
        switch authResult {
        case .success(let authData):
            HapticService.shared.success()
            createOrLoadUser(authData: authData)
            
        case .failure(let error):
            isLoading = false
            HapticService.shared.error()
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    #endif
    
    private func handleCompletion(_ result: Result<ASAuthorization, Error>) {
        isLoading = true
        
        let authResult = AuthenticationService.shared.handleAuthorization(result: result)
        
        switch authResult {
        case .success(let authData):
            HapticService.shared.success()
            createOrLoadUser(authData: authData)
            
        case .failure(let error):
            isLoading = false
            if case .canceled = error {
                // User canceled, don't show error
                return
            }
            HapticService.shared.error()
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func createOrLoadUser(authData: AuthData) {
        // Check if user already exists
        let targetUserId = authData.userId
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.appleUserIdentifier == targetUserId }
        )
        
        do {
            let existingUsers = try modelContext.fetch(descriptor)
            
            if let existingUser = existingUsers.first {
                // User exists, update last active
                existingUser.updateLastActive()
                appState.signIn(user: existingUser)
                
                // Check if they have journals
                if !existingUser.journals.isEmpty,
                   let firstJournal = existingUser.journals.first,
                   let language = firstJournal.language {
                    appState.selectLanguage(language, journal: firstJournal)
                }
            } else {
                // Create new user
                let newUser = User(
                    appleUserIdentifier: authData.userId,
                    email: authData.email
                )
                modelContext.insert(newUser)
                try modelContext.save()
                appState.signIn(user: newUser)
            }
        } catch {
            errorMessage = "Failed to save user data"
            showError = true
        }
        
        isLoading = false
    }
}

#Preview {
    WelcomeView()
        .environment(AppState())
        .modelContainer(for: [User.self, Journal.self, StickerWord.self], inMemory: true)
}
