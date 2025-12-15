import SwiftUI

// MARK: - Language Picker View (Onboarding)

struct LanguagePickerView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.backgroundFallback
                    .ignoresSafeArea()
                
                DottedGridBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: Theme.Spacing.xl) {
                    // Header
                    VStack(spacing: Theme.Spacing.sm) {
                        Text("What language do you want to learn?")
                            .font(Theme.Typography.headline(24))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("You can change this anytime")
                            .font(Theme.Typography.body(14))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.xl)
                    
                    // Language grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: Theme.Spacing.md) {
                        ForEach(Language.allCases) { language in
                            LanguageOptionCard(
                                language: language,
                                isSelected: appState.currentLanguage == language,
                                action: {
                                    appState.selectLanguage(language)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    Spacer()
                    
                    // Continue button
                    PrimaryButton(title: "Continue") {
                        dismiss()
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.bottom, Theme.Spacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Language Option Card

struct LanguageOptionCard: View {
    
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.sm) {
                Text(language.flag)
                    .font(.system(size: 40))
                
                Text(language.displayName)
                    .font(Theme.Typography.bodyBold(14))
                    .foregroundColor(isSelected ? .white : Theme.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .fill(isSelected ? Theme.Colors.primaryFallback : Color.black.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .stroke(isSelected ? Theme.Colors.primaryFallback : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    LanguagePickerView()
        .environment(AppState())
}
