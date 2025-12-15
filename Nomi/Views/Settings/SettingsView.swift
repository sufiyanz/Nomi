//
//  SettingsView.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var notificationsEnabled = false
    @State private var reminderTime = Date()
    @State private var showSignOutAlert = false
    @State private var isLoadingNotifications = true
    
    @StateObject private var notificationService = NotificationService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.nomiBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: NomiSpacing.large) {
                        // Notifications Section
                        notificationsSection
                        
                        // Account Section
                        accountSection
                        
                        // About Section
                        aboutSection
                        
                        Spacer(minLength: NomiSpacing.huge)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.nomiPink)
                    .fontWeight(.semibold)
                }
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out? Your data will remain on this device.")
            }
            .onAppear {
                loadSettings()
            }
        }
    }
    
    // MARK: - Notifications Section
    
    private var notificationsSection: some View {
        SettingsSection(title: "Notifications", icon: "🔔") {
            VStack(spacing: NomiSpacing.medium) {
                // Enable toggle
                Toggle(isOn: $notificationsEnabled) {
                    HStack {
                        Text("Daily Reminder")
                            .font(.nomiBody())
                            .foregroundColor(.nomiTextDark)
                    }
                }
                .tint(.nomiPink)
                .onChange(of: notificationsEnabled) { _, newValue in
                    handleNotificationToggle(newValue)
                }
                
                // Time picker (shown if enabled)
                if notificationsEnabled {
                    Divider()
                    
                    DatePicker(
                        "Reminder Time",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .font(.nomiBody())
                    .onChange(of: reminderTime) { _, newTime in
                        updateReminderTime(newTime)
                    }
                    
                    // Preview
                    HStack {
                        Text("✨")
                        Text("Time to collect new words!")
                            .font(.nomiCaption())
                            .foregroundColor(.nomiTextLight)
                            .italic()
                    }
                    .padding(.top, NomiSpacing.tiny)
                }
            }
        }
    }
    
    // MARK: - Account Section
    
    private var accountSection: some View {
        SettingsSection(title: "Account", icon: "👤") {
            VStack(spacing: NomiSpacing.medium) {
                // Apple ID
                if let email = appState.currentUser?.email {
                    HStack {
                        Text("Apple ID")
                            .font(.nomiBody())
                            .foregroundColor(.nomiTextDark)
                        Spacer()
                        Text(email)
                            .font(.nomiCaption())
                            .foregroundColor(.nomiTextLight)
                    }
                    
                    Divider()
                }
                
                // Sign out button
                Button {
                    showSignOutAlert = true
                } label: {
                    HStack {
                        Text("Sign Out")
                            .font(.nomiBody())
                            .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "arrow.right.square")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        SettingsSection(title: "About", icon: "ℹ️") {
            VStack(spacing: NomiSpacing.medium) {
                // Version
                HStack {
                    Text("Version")
                        .font(.nomiBody())
                        .foregroundColor(.nomiTextDark)
                    Spacer()
                    Text("\(Config.appVersion) (\(Config.buildNumber))")
                        .font(.nomiCaption())
                        .foregroundColor(.nomiTextLight)
                }
                
                Divider()
                
                // Privacy Policy
                Link(destination: Config.privacyPolicyURL) {
                    HStack {
                        Text("Privacy Policy")
                            .font(.nomiBody())
                            .foregroundColor(.nomiTextDark)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.nomiTextLight)
                    }
                }
                
                Divider()
                
                // Terms of Service
                Link(destination: Config.termsOfServiceURL) {
                    HStack {
                        Text("Terms of Service")
                            .font(.nomiBody())
                            .foregroundColor(.nomiTextDark)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.nomiTextLight)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadSettings() {
        // Load notification settings from user
        if let user = appState.currentUser {
            notificationsEnabled = user.notificationsEnabled
            
            var components = DateComponents()
            components.hour = user.reminderHour
            components.minute = user.reminderMinute
            if let time = Calendar.current.date(from: components) {
                reminderTime = time
            }
        }
        isLoadingNotifications = false
    }
    
    private func handleNotificationToggle(_ enabled: Bool) {
        Task {
            if enabled {
                let granted = await notificationService.requestAuthorization()
                
                await MainActor.run {
                    if granted {
                        scheduleReminder()
                        saveNotificationSettings(enabled: true)
                    } else {
                        notificationsEnabled = false
                    }
                }
            } else {
                await notificationService.cancelDailyReminder()
                saveNotificationSettings(enabled: false)
            }
        }
    }
    
    private func updateReminderTime(_ time: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        
        if let user = appState.currentUser {
            user.reminderHour = components.hour ?? Config.defaultReminderHour
            user.reminderMinute = components.minute ?? Config.defaultReminderMinute
            try? modelContext.save()
        }
        
        if notificationsEnabled {
            scheduleReminder()
        }
    }
    
    private func scheduleReminder() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        
        Task {
            await notificationService.scheduleDailyReminder(
                at: components.hour ?? Config.defaultReminderHour,
                minute: components.minute ?? Config.defaultReminderMinute
            )
        }
    }
    
    private func saveNotificationSettings(enabled: Bool) {
        if let user = appState.currentUser {
            user.notificationsEnabled = enabled
            try? modelContext.save()
        }
    }
    
    private func signOut() {
        HapticService.shared.tap()
        appState.signOut()
        dismiss()
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: NomiSpacing.small) {
            // Section header
            HStack(spacing: NomiSpacing.small) {
                Text(icon)
                Text(title)
                    .font(.nomiSubheadline())
                    .foregroundColor(.nomiTextLight)
            }
            
            // Section content
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .padding()
            .background(Color.nomiCardBackground)
            .cornerRadius(NomiRadius.medium)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
        .modelContainer(for: [User.self, Journal.self, StickerWord.self], inMemory: true)
}
