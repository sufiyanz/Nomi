import SwiftUI
import AuthenticationServices

// MARK: - Welcome View

struct WelcomeView: View {
    
    @Environment(AppState.self) private var appState
    @State private var showStickers = false
    
    var body: some View {
        ZStack {
            // Background
            Theme.Colors.backgroundFallback
                .ignoresSafeArea()
            
            // Dotted grid pattern
            DottedGridBackground()
                .ignoresSafeArea()
            
            // Floating stickers
            floatingStickers
            
            // Main content
            VStack(spacing: Theme.Spacing.xl) {
                Spacer()
                
                // Logo
                logoSection
                
                // Tagline
                taglineSection
                
                Spacer()
                
                // Sign in button
                signInSection
                
                // Footer
                footerSection
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.lg)
        }
        .onAppear {
            withAnimation(Theme.Animation.slow.delay(0.3)) {
                showStickers = true
            }
        }
    }
    
    // MARK: - Logo Section
    
    private var logoSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            // App icon placeholder
            RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.8), Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Text("nomi")
                        .font(Theme.Typography.headline(24))
                        .foregroundColor(Theme.Colors.primaryFallback)
                )
                .scaleAppear()
        }
    }
    
    // MARK: - Tagline Section
    
    private var taglineSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text("Less gamified guilt.")
                .font(Theme.Typography.headline(28))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("More real-world recall.")
                .font(Theme.Typography.headline(28))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("Open it in a cinema, café or train and collect stickers from the room.")
                .font(Theme.Typography.body(16))
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, Theme.Spacing.xs)
        }
        .slideUp(delay: 0.2)
    }
    
    // MARK: - Sign In Section
    
    private var signInSection: some View {
        SignInWithAppleButton(.continue) { request in
            request.requestedScopes = [.email]
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                handleSignIn(authorization)
            case .failure(let error):
                print("Sign in failed: \(error)")
            }
        }
        .signInWithAppleButtonStyle(.white)
        .frame(height: 54)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.large))
        .slideUp(delay: 0.4)
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text("By pressing on \"Continue with...\" you agree to our")
                .font(Theme.Typography.caption(12))
                .foregroundColor(Theme.Colors.textMuted)
            
            HStack(spacing: Theme.Spacing.xxs) {
                Link("Terms of Service", destination: Config.URLs.termsOfService)
                    .font(Theme.Typography.caption(12))
                    .foregroundColor(Theme.Colors.primaryFallback)
                
                Text("and")
                    .font(Theme.Typography.caption(12))
                    .foregroundColor(Theme.Colors.textMuted)
                
                Link("Privacy Policy", destination: Config.URLs.privacyPolicy)
                    .font(Theme.Typography.caption(12))
                    .foregroundColor(Theme.Colors.primaryFallback)
            }
        }
        .multilineTextAlignment(.center)
        .slideUp(delay: 0.5)
    }
    
    // MARK: - Floating Stickers
    
    private var floatingStickers: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Group {
                // Top left - coffee
                stickerView(emoji: "☕️", size: 60)
                    .position(x: width * 0.15, y: height * 0.12)
                    .floating(amplitude: 10, duration: 3.0, delay: 0)
                
                // Top right - croissant
                stickerView(emoji: "🥐", size: 50)
                    .position(x: width * 0.85, y: height * 0.15)
                    .floating(amplitude: 8, duration: 2.8, delay: 0.5)
                
                // Left middle - salad
                stickerView(emoji: "🥗", size: 55)
                    .position(x: width * 0.1, y: height * 0.45)
                    .floating(amplitude: 12, duration: 3.2, delay: 0.3)
                
                // Right middle - stapler
                stickerView(emoji: "📎", size: 45)
                    .position(x: width * 0.92, y: height * 0.5)
                    .floating(amplitude: 9, duration: 2.6, delay: 0.7)
                
                // Bottom left - tea
                stickerView(emoji: "🍵", size: 50)
                    .position(x: width * 0.12, y: height * 0.75)
                    .floating(amplitude: 11, duration: 3.1, delay: 0.2)
                
                // Bottom right - book
                stickerView(emoji: "📖", size: 55)
                    .position(x: width * 0.88, y: height * 0.78)
                    .floating(amplitude: 10, duration: 2.9, delay: 0.6)
            }
            .opacity(showStickers ? 1 : 0)
        }
    }
    
    private func stickerView(emoji: String, size: CGFloat) -> some View {
        Circle()
            .fill(Theme.Colors.cardBackground)
            .frame(width: size, height: size)
            .overlay(
                Text(emoji)
                    .font(.system(size: size * 0.5))
            )
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Helpers
    
    private func handleSignIn(_ authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        // The AuthenticationService handles the actual sign-in
        // This is triggered via the SignInWithAppleButton
        Task {
            await appState.signIn()
        }
    }
}

// MARK: - Preview

#Preview {
    WelcomeView()
        .environment(AppState())
}
