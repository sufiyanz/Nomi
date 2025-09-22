import SwiftUI

struct AdhanView: View {
    @StateObject private var prayerTimesManager = PrayerTimesManager.shared
    @StateObject private var audioManager = AdhanAudioManager.shared
    @StateObject private var locationManager = LocationManager.shared
    @State private var showingSettings = false
    @State private var showingLocationPicker = false
    @State private var selectedPrayerForAdhan: PrayerName?
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                ScrollView {
                    VStack(spacing: DesignTokens.containerSpacing) {
                        headerSection
                        nextPrayerCard
                        todayPrayerTimesCard
                        audioControlsCard
                        quickActionsCard
                    }
                    .padding()
                }
            }
            .navigationTitle("Prayer Times")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Settings", systemImage: "gear") {
                            showingSettings = true
                        }
                        
                        Button("Change Location", systemImage: "location") {
                            showingLocationPicker = true
                        }
                        
                        Button("Refresh", systemImage: "arrow.clockwise") {
                            Task {
                                await prayerTimesManager.refreshPrayerTimes()
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                Task {
                    await prayerTimesManager.initialize()
                }
            }
            .refreshable {
                await prayerTimesManager.refreshPrayerTimes()
            }
            .sheet(isPresented: $showingSettings) {
                PrayerTimesSettingsView()
            }
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerView()
            }
            .alert("Play Adhan", isPresented: .constant(selectedPrayerForAdhan != nil)) {
                Button("Play") {
                    if let prayer = selectedPrayerForAdhan {
                        Task {
                            await audioManager.playAdhan(for: prayer)
                        }
                    }
                    selectedPrayerForAdhan = nil
                }
                Button("Cancel", role: .cancel) {
                    selectedPrayerForAdhan = nil
                }
            } message: {
                if let prayer = selectedPrayerForAdhan {
                    Text("Play Adhan for \(prayer.displayName)?")
                }
            }
        }
    }
    
    private var headerSection: some View {
        GlassEffectContainer {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                    
                    Text("Prayer Times")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if prayerTimesManager.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                
                if let location = locationManager.currentPrayerLocation {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(locationDisplayText(location))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
                
                if let lastUpdate = prayerTimesManager.lastUpdateDate {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Updated \(lastUpdate, formatter: relativeDateFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var nextPrayerCard: some View {
        Group {
            if let nextPrayer = prayerTimesManager.nextPrayer {
                NextPrayerCard(prayer: nextPrayer, timeUntil: prayerTimesManager.getTimeUntilNextPrayer())
            } else if let currentPrayer = prayerTimesManager.currentPrayer {
                CurrentPrayerCard(prayer: currentPrayer)
            } else {
                GlassEffectContainer {
                    VStack {
                        Image(systemName: "moon.zzz")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No upcoming prayers today")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
        }
    }
    
    private var todayPrayerTimesCard: some View {
        GlassEffectContainer {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Today's Prayer Times")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(Date(), formatter: dateFormatter)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let prayerTimes = prayerTimesManager.currentPrayerTimes {
                    VStack(spacing: 12) {
                        ForEach(prayerTimes.obligatoryPrayers, id: \.name) { prayer in
                            PrayerTimeRow(
                                prayer: prayer,
                                isNext: prayer.name == prayerTimesManager.nextPrayer?.name,
                                isCurrent: prayer.name == prayerTimesManager.currentPrayer?.name
                            ) {
                                selectedPrayerForAdhan = prayer.name
                            }
                        }
                    }
                } else if prayerTimesManager.isLoading {
                    HStack {
                        ProgressView()
                        Text("Loading prayer times...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else if let error = prayerTimesManager.lastError {
                    ErrorView(error: error) {
                        Task {
                            await prayerTimesManager.refreshPrayerTimes()
                        }
                    }
                } else {
                    Text("No prayer times available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
    }
    
    private var audioControlsCard: some View {
        Group {
            if audioManager.playbackState != .stopped {
                GlassEffectContainer {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Now Playing")
                                .font(.headline)
                            
                            Spacer()
                            
                            if let recording = audioManager.currentRecording {
                                Text(recording.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        AudioControlsView()
                    }
                }
            }
        }
    }
    
    private var quickActionsCard: some View {
        GlassEffectContainer {
            VStack(alignment: .leading, spacing: 16) {
                Text("Quick Actions")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    QuickActionButton(
                        title: "Find Qibla",
                        icon: "safari",
                        color: .green
                    ) {
                        // TODO: Implement Qibla direction
                    }
                    
                    QuickActionButton(
                        title: "Settings",
                        icon: "gear",
                        color: .blue
                    ) {
                        showingSettings = true
                    }
                    
                    QuickActionButton(
                        title: "Location",
                        icon: "location",
                        color: .orange
                    ) {
                        showingLocationPicker = true
                    }
                    
                    QuickActionButton(
                        title: "Calendar",
                        icon: "calendar",
                        color: .purple
                    ) {
                        // TODO: Navigate to Islamic calendar
                    }
                }
            }
        }
    }
    
    private func locationDisplayText(_ location: PrayerLocation) -> String {
        if let city = location.city, let country = location.country {
            return "\(city), \(country)"
        } else if let city = location.city {
            return city
        } else if let country = location.country {
            return country
        } else {
            return String(format: "%.2f°, %.2f°", location.latitude, location.longitude)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
    
    private var relativeDateFormatter: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }
}

// MARK: - Supporting Views

struct NextPrayerCard: View {
    let prayer: PrayerTime
    let timeUntil: String
    
    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 16) {
                HStack {
                    Text("Next Prayer")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(prayer.name.displayName)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(prayer.name.arabicName)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(prayer.displayTime)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        
                        Text("in \(timeUntil)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                ProgressView(value: 1.0 - (prayer.timeUntil / (24 * 3600)))
                    .tint(.purple)
            }
        }
    }
}

struct CurrentPrayerCard: View {
    let prayer: PrayerTime
    
    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 16) {
                HStack {
                    Text("Current Prayer Time")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Image(systemName: "bell.fill")
                        .foregroundColor(.green)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(prayer.name.displayName)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(prayer.name.arabicName)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(prayer.displayTime)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Text("Prayer time is now")
                    .font(.caption)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct PrayerTimeRow: View {
    let prayer: PrayerTime
    let isNext: Bool
    let isCurrent: Bool
    let onPlayAdhan: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: prayer.name.icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(prayer.name.displayName)
                        .font(.body)
                        .fontWeight(isNext || isCurrent ? .semibold : .regular)
                    
                    Text(prayer.name.arabicName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Text(prayer.displayTime)
                    .font(.body)
                    .fontWeight(isNext || isCurrent ? .semibold : .regular)
                    .foregroundColor(timeColor)
                
                Button(action: onPlayAdhan) {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .opacity(isNext || isCurrent ? 0.1 : 0)
        )
    }
    
    private var iconColor: Color {
        if isCurrent { return .green }
        if isNext { return .purple }
        return .primary
    }
    
    private var timeColor: Color {
        if isCurrent { return .green }
        if isNext { return .purple }
        return .primary
    }
    
    private var backgroundColor: Color {
        if isCurrent { return .green }
        if isNext { return .purple }
        return .clear
    }
}

struct AudioControlsView: View {
    @ObservedObject var audioManager = AdhanAudioManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            // Progress bar
            if audioManager.duration > 0 {
                ProgressView(value: audioManager.playbackProgress)
                    .tint(.purple)
                
                HStack {
                    Text(formatTime(audioManager.currentTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatTime(audioManager.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Playback controls
            HStack(spacing: 20) {
                Button(action: { audioManager.stop() }) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                }
                .disabled(audioManager.playbackState == .stopped)
                
                Spacer()
                
                Button(action: togglePlayback) {
                    Image(systemName: playButtonIcon)
                        .font(.title)
                }
                .disabled(audioManager.playbackState == .loading)
                
                Spacer()
                
                VolumeControlView()
                    .frame(width: 100)
            }
        }
    }
    
    private func togglePlayback() {
        switch audioManager.playbackState {
        case .playing:
            audioManager.pause()
        case .paused, .stopped:
            audioManager.resume()
        default:
            break
        }
    }
    
    private var playButtonIcon: String {
        switch audioManager.playbackState {
        case .playing:
            return "pause.circle.fill"
        case .loading:
            return "hourglass"
        default:
            return "play.circle.fill"
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
                    .opacity(0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ErrorView: View {
    let error: PrayerTimesError
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.orange)
            
            Text("Error Loading Prayer Times")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Placeholder Views
struct PrayerTimesSettingsView: View {
    var body: some View {
        NavigationView {
            Text("Prayer Times Settings")
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LocationPickerView: View {
    var body: some View {
        NavigationView {
            Text("Location Picker")
                .navigationTitle("Location")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AdhanView()
}
