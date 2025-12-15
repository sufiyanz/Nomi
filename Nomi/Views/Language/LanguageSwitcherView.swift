import SwiftUI

// MARK: - Language Switcher View

struct LanguageSwitcherView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.cardBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.xs) {
                        ForEach(Language.allCases) { language in
                            LanguageRow(
                                language: language,
                                isSelected: appState.currentLanguage == language,
                                action: {
                                    appState.selectLanguage(language)
                                    dismiss()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                }
            }
            .navigationTitle("Choose Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.primaryFallback)
                }
            }
        }
    }
}

// MARK: - Language Row

struct LanguageRow: View {
    
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                Text(language.flag)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(language.displayName)
                        .font(Theme.Typography.bodyBold(16))
                        .foregroundColor(Theme.Colors.cardText)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.Colors.primaryFallback)
                }
            }
            .padding(.vertical, Theme.Spacing.md)
            .padding(.horizontal, Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(isSelected ? Theme.Colors.primaryFallback.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    LanguageSwitcherView()
        .environment(AppState())
}
