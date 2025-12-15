import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    @State private var dailyReminderEnabled = false
    @State private var reminderTime = Date()
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.cardBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Notifications section
                        notificationsSection
                        
                        // Account section
                        accountSection
                        
                        // About section
                        aboutSection
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.md)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CloseButton(
                        action: { dismiss() },
                        backgroundColor: Theme.Colors.textMuted.opacity(0.2),
                        foregroundColor: Theme.Colors.cardText
                    )
                }
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .onAppear {
                loadSettings()
            }
        }
    }
    
    // MARK: - Notifications Section
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            sectionHeader("Notifications")
            
            VStack(spacing: 0) {
                // Daily reminder toggle
                HStack {
                    Label("Daily reminder", systemImage: "bell.fill")
                        .font(Theme.Typography.body(16))
                        .foregroundColor(Theme.Colors.cardText)
                    
                    Spacer()
                    
                    Toggle("", isOn: $dailyReminderEnabled)
                        .tint(Theme.Colors.primaryFallback)
                        .onChange(of: dailyReminderEnabled) { _, newValue in
                            handleReminderToggle(newValue)
                        }
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.md)
                
                // Time picker (shown when reminder is enabled)
                if dailyReminderEnabled {
                    Divider()
                        .padding(.horizontal, Theme.Spacing.md)
                    
                    HStack {
                        Label("Reminder time", systemImage: "clock.fill")
                            .font(Theme.Typography.body(16))
                            .foregroundColor(Theme.Colors.cardText)
                        
                        Spacer()
                        
                        DatePicker(
                            "",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .tint(Theme.Colors.primaryFallback)
                        .onChange(of: reminderTime) { _, newValue in
                            handleTimeChange(newValue)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.md)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        }
    }
    
    // MARK: - Account Section
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            sectionHeader("Account")
            
            VStack(spacing: 0) {
                // Apple ID
                HStack {
                    Label("Apple ID", systemImage: "person.fill")
                        .font(Theme.Typography.body(16))
                        .foregroundColor(Theme.Colors.cardText)
                    
                    Spacer()
                    
                    Text(appState.authService.currentUserEmail ?? "Not available")
                        .font(Theme.Typography.body(14))
                        .foregroundColor(Theme.Colors.textMuted)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.md)
                
                Divider()
                    .padding(.horizontal, Theme.Spacing.md)
                
                // Sign out
                Button(action: { showSignOutAlert = true }) {
                    HStack {
                        Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(Theme.Typography.body(16))
                            .foregroundColor(Theme.Colors.destructive)
                        
                        Spacer()
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.md)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            sectionHeader("About")
            
            VStack(spacing: 0) {
                // Version
                HStack {
                    Label("Version", systemImage: "info.circle.fill")
                        .font(Theme.Typography.body(16))
                        .foregroundColor(Theme.Colors.cardText)
                    
                    Spacer()
                    
                    Text(Config.App.version)
                        .font(Theme.Typography.body(14))
                        .foregroundColor(Theme.Colors.textMuted)
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.md)
                
                Divider()
                    .padding(.horizontal, Theme.Spacing.md)
                
                // Privacy Policy
                Link(destination: Config.URLs.privacyPolicy) {
                    HStack {
                        Label("Privacy policy", systemImage: "hand.raised.fill")
                            .font(Theme.Typography.body(16))
                            .foregroundColor(Theme.Colors.cardText)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.Colors.textMuted)
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.md)
                }
                
                Divider()
                    .padding(.horizontal, Theme.Spacing.md)
                
                // Terms of Service
                Link(destination: Config.URLs.termsOfService) {
                    HStack {
                        Label("Terms of service", systemImage: "doc.text.fill")
                            .font(Theme.Typography.body(16))
                            .foregroundColor(Theme.Colors.cardText)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.Colors.textMuted)
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.md)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        }
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(Theme.Typography.caption(12))
            .foregroundColor(Theme.Colors.textMuted)
            .padding(.leading, Theme.Spacing.xs)
    }
    
    private func loadSettings() {
        // Load from UserDefaults
        dailyReminderEnabled = UserDefaults.standard.bool(forKey: "dailyReminderEnabled")
        
        if let savedTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date {
            reminderTime = savedTime
        } else {
            // Default to 9:00 AM
            reminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        }
    }
    
    private func handleReminderToggle(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "dailyReminderEnabled")
        
        Task {
            if enabled {
                // Request permission and schedule
                let granted = await appState.notificationService.requestAuthorization()
                if granted {
                    await appState.notificationService.scheduleDailyReminder(at: reminderTime)
                } else {
                    dailyReminderEnabled = false
                }
            } else {
                await appState.notificationService.cancelDailyReminder()
            }
        }
        
        appState.hapticService.selectionChanged()
    }
    
    private func handleTimeChange(_ time: Date) {
        UserDefaults.standard.set(time, forKey: "reminderTime")
        
        if dailyReminderEnabled {
            Task {
                await appState.notificationService.scheduleDailyReminder(at: time)
            }
        }
    }
    
    private func signOut() {
        appState.signOut()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environment(AppState())
}
