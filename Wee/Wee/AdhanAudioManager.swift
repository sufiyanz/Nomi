import Foundation
import AVFoundation
import Combine
import MediaPlayer
import SwiftUI

// MARK: - Adhan Audio Models
struct AdhanRecording {
    let id: String
    let name: String
    let reciter: String
    let fileName: String
    let duration: TimeInterval
    let language: AdhanLanguage
    let style: AdhanStyle
    let isBuiltIn: Bool
    
    var displayName: String {
        return "\(name) - \(reciter)"
    }
    
    var fileURL: URL? {
        if isBuiltIn {
            return Bundle.main.url(forResource: fileName, withExtension: "mp3")
        } else {
            // Custom recordings in Documents directory
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentsPath?.appendingPathComponent("\(fileName).mp3")
        }
    }
}

enum AdhanLanguage: String, CaseIterable {
    case arabic = "arabic"
    case mixed = "mixed" // Arabic with some local language
    
    var displayName: String {
        switch self {
        case .arabic: return "Arabic"
        case .mixed: return "Mixed"
        }
    }
}

enum AdhanStyle: String, CaseIterable {
    case traditional = "traditional"
    case modern = "modern"
    case melodic = "melodic"
    case simple = "simple"
    
    var displayName: String {
        switch self {
        case .traditional: return "Traditional"
        case .modern: return "Modern"
        case .melodic: return "Melodic"
        case .simple: return "Simple"
        }
    }
}

// MARK: - Audio Playback State
enum AudioPlaybackState: Equatable {
    case stopped
    case playing
    case paused
    case loading
    case error(AudioError)
    
    static func == (lhs: AudioPlaybackState, rhs: AudioPlaybackState) -> Bool {
        switch (lhs, rhs) {
        case (.stopped, .stopped):
            return true
        case (.playing, .playing):
            return true
        case (.paused, .paused):
            return true
        case (.loading, .loading):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

// MARK: - Adhan Audio Manager
@MainActor
class AdhanAudioManager: NSObject, ObservableObject {
    static let shared = AdhanAudioManager()
    
    @Published var playbackState: AudioPlaybackState = .stopped
    @Published var currentRecording: AdhanRecording?
    @Published var playbackProgress: Double = 0.0
    @Published var currentTime: TimeInterval = 0.0
    @Published var duration: TimeInterval = 0.0
    @Published var volume: Float = 0.7
    @Published var isMuted: Bool = false
    @Published var availableRecordings: [AdhanRecording] = []
    
    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    private var audioSession: AVAudioSession
    private var cancellables = Set<AnyCancellable>()
    
    // Audio preferences
    private let preferences = AdhanAudioPreferences.shared
    
    override init() {
        self.audioSession = AVAudioSession.sharedInstance()
        super.init()
        
        setupAudioSession()
        loadBuiltInRecordings()
        setupAudioPreferences()
        setupRemoteControls()
    }
    
    // MARK: - Public Methods
    
    func playAdhan(for prayer: PrayerName, recording: AdhanRecording? = nil) async {
        let selectedRecording = recording ?? getRecordingForPrayer(prayer) ?? getDefaultRecording()
        
        guard let recording = selectedRecording else {
            playbackState = .error(.noRecordingAvailable)
            return
        }
        
        await playRecording(recording)
    }
    
    func playRecording(_ recording: AdhanRecording) async {
        playbackState = .loading
        currentRecording = recording
        
        do {
            try await setupAudioPlayer(for: recording)
            audioPlayer?.play()
            playbackState = .playing
            startProgressTimer()
            updateNowPlayingInfo()
            
        } catch {
            playbackState = .error(.playbackFailed(error))
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        playbackState = .paused
        stopProgressTimer()
    }
    
    func resume() {
        audioPlayer?.play()
        playbackState = .playing
        startProgressTimer()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        playbackState = .stopped
        currentRecording = nil
        currentTime = 0.0
        playbackProgress = 0.0
        stopProgressTimer()
        clearNowPlayingInfo()
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
        updateProgress()
    }
    
    func setVolume(_ volume: Float) {
        self.volume = max(0.0, min(1.0, volume))
        audioPlayer?.volume = isMuted ? 0.0 : self.volume
        preferences.volume = self.volume
    }
    
    func toggleMute() {
        isMuted.toggle()
        audioPlayer?.volume = isMuted ? 0.0 : volume
        preferences.isMuted = isMuted
    }
    
    func getRecordingForPrayer(_ prayer: PrayerName) -> AdhanRecording? {
        let recordingId = preferences.getRecordingId(for: prayer)
        return availableRecordings.first { $0.id == recordingId }
    }
    
    func setRecording(_ recording: AdhanRecording, for prayer: PrayerName) {
        preferences.setRecordingId(recording.id, for: prayer)
    }
    
    func getDefaultRecording() -> AdhanRecording? {
        return availableRecordings.first { $0.isBuiltIn }
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupAudioPlayer(for recording: AdhanRecording) async throws {
        guard let url = recording.fileURL else {
            throw AudioError.fileNotFound
        }
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw AudioError.fileNotFound
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = isMuted ? 0.0 : volume
            
            duration = audioPlayer?.duration ?? 0.0
            currentTime = 0.0
            playbackProgress = 0.0
            
        } catch {
            throw AudioError.invalidAudioFile
        }
    }
    
    private func loadBuiltInRecordings() {
        // In a real app, these would be actual audio files in the bundle
        let builtInRecordings = [
            AdhanRecording(
                id: "default_traditional",
                name: "Traditional Adhan",
                reciter: "Sheikh Abdul Basit",
                fileName: "adhan_traditional",
                duration: 180.0,
                language: .arabic,
                style: .traditional,
                isBuiltIn: true
            ),
            AdhanRecording(
                id: "modern_melodic",
                name: "Melodic Adhan",
                reciter: "Sheikh Mishary Rashid",
                fileName: "adhan_melodic",
                duration: 210.0,
                language: .arabic,
                style: .melodic,
                isBuiltIn: true
            ),
            AdhanRecording(
                id: "simple_call",
                name: "Simple Call",
                reciter: "Sheikh Saad Al Ghamdi",
                fileName: "adhan_simple",
                duration: 120.0,
                language: .arabic,
                style: .simple,
                isBuiltIn: true
            )
        ]
        
        availableRecordings = builtInRecordings
    }
    
    private func setupAudioPreferences() {
        volume = preferences.volume
        isMuted = preferences.isMuted
    }
    
    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                self.updateProgress()
            }
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func updateProgress() {
        guard let player = audioPlayer else { return }
        
        currentTime = player.currentTime
        
        if duration > 0 {
            playbackProgress = currentTime / duration
        }
    }
    
    // MARK: - Remote Controls and Now Playing
    
    private func setupRemoteControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { _ in
            if self.playbackState == .paused {
                self.resume()
            }
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { _ in
            if self.playbackState == .playing {
                self.pause()
            }
            return .success
        }
        
        commandCenter.stopCommand.addTarget { _ in
            self.stop()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self.seek(to: event.positionTime)
                return .success
            }
            return .commandFailed
        }
    }
    
    private func updateNowPlayingInfo() {
        guard let recording = currentRecording else { return }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Adhan"
        nowPlayingInfo[MPMediaItemPropertyArtist] = recording.reciter
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = recording.name
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playbackState == .playing ? 1.0 : 0.0
        
        // Add artwork if available
        if let image = getAdhanArtwork() {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func clearNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    private func getAdhanArtwork() -> UIImage? {
        // Return a default Islamic artwork or app icon
        return UIImage(systemName: "moon.stars.fill")
    }
}

// MARK: - AVAudioPlayerDelegate
extension AdhanAudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            stop()
        } else {
            playbackState = .error(.playbackInterrupted)
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        playbackState = .error(.decodingError(error))
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        pause()
    }
    
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        if flags == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
            resume()
        }
    }
}

// MARK: - Audio Preferences Manager
class AdhanAudioPreferences {
    static let shared = AdhanAudioPreferences()
    
    private let userDefaults = UserDefaults.standard
    private let volumeKey = "AdhanVolume"
    private let mutedKey = "AdhanMuted"
    private let recordingPrefix = "AdhanRecording_"
    private let autoPlayKey = "AdhanAutoPlay"
    private let silentModeKey = "AdhanSilentMode"
    
    private init() {}
    
    var volume: Float {
        get {
            let volume = userDefaults.float(forKey: volumeKey)
            return volume == 0 ? 0.7 : volume // Default to 0.7 if not set
        }
        set {
            userDefaults.set(newValue, forKey: volumeKey)
        }
    }
    
    var isMuted: Bool {
        get {
            userDefaults.bool(forKey: mutedKey)
        }
        set {
            userDefaults.set(newValue, forKey: mutedKey)
        }
    }
    
    var isAutoPlayEnabled: Bool {
        get {
            userDefaults.bool(forKey: autoPlayKey)
        }
        set {
            userDefaults.set(newValue, forKey: autoPlayKey)
        }
    }
    
    var respectSilentMode: Bool {
        get {
            userDefaults.bool(forKey: silentModeKey)
        }
        set {
            userDefaults.set(newValue, forKey: silentModeKey)
        }
    }
    
    func getRecordingId(for prayer: PrayerName) -> String? {
        return userDefaults.string(forKey: recordingPrefix + prayer.rawValue)
    }
    
    func setRecordingId(_ recordingId: String, for prayer: PrayerName) {
        userDefaults.set(recordingId, forKey: recordingPrefix + prayer.rawValue)
    }
    
    func clearRecordingPreference(for prayer: PrayerName) {
        userDefaults.removeObject(forKey: recordingPrefix + prayer.rawValue)
    }
    
    func clearAllPreferences() {
        let keys = [volumeKey, mutedKey, autoPlayKey, silentModeKey]
        keys.forEach { userDefaults.removeObject(forKey: $0) }
        
        // Clear prayer-specific recordings
        PrayerName.allCases.forEach { prayer in
            clearRecordingPreference(for: prayer)
        }
    }
}

// MARK: - Audio Errors
enum AudioError: LocalizedError {
    case noRecordingAvailable
    case fileNotFound
    case invalidAudioFile
    case playbackFailed(Error)
    case decodingError(Error?)
    case playbackInterrupted
    case audioSessionFailed
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .noRecordingAvailable:
            return "No adhan recording is available."
        case .fileNotFound:
            return "Audio file not found."
        case .invalidAudioFile:
            return "Invalid audio file format."
        case .playbackFailed(let error):
            return "Playback failed: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Audio decoding error: \(error?.localizedDescription ?? "Unknown")"
        case .playbackInterrupted:
            return "Audio playback was interrupted."
        case .audioSessionFailed:
            return "Failed to configure audio session."
        case .permissionDenied:
            return "Audio playback permission denied."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noRecordingAvailable:
            return "Please select an adhan recording in settings."
        case .fileNotFound:
            return "Please reinstall the app or download the audio files again."
        case .invalidAudioFile:
            return "Please try a different audio file."
        case .playbackFailed, .decodingError:
            return "Please try again or restart the app."
        case .playbackInterrupted:
            return "Please try playing the adhan again."
        case .audioSessionFailed:
            return "Check your device's audio settings and try again."
        case .permissionDenied:
            return "Enable audio permissions in Settings."
        }
    }
}

// MARK: - Volume Control View
struct VolumeControlView: View {
    @ObservedObject var audioManager = AdhanAudioManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .foregroundColor(audioManager.isMuted ? .red : .primary)
                
                Slider(value: Binding(
                    get: { audioManager.volume },
                    set: { audioManager.setVolume($0) }
                ), in: 0...1) {
                    Text("Volume")
                } minimumValueLabel: {
                    Image(systemName: "speaker.fill")
                        .foregroundColor(.secondary)
                } maximumValueLabel: {
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundColor(.secondary)
                }
                .disabled(audioManager.isMuted)
                
                Button(action: { audioManager.toggleMute() }) {
                    Image(systemName: audioManager.isMuted ? "speaker.slash.circle.fill" : "speaker.circle")
                        .foregroundColor(audioManager.isMuted ? .red : .blue)
                }
            }
            
            Text("Volume: \(Int(audioManager.volume * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Audio Recording Selection View
struct AdhanRecordingSelectionView: View {
    let prayer: PrayerName
    @ObservedObject var audioManager = AdhanAudioManager.shared
    @State private var selectedRecording: AdhanRecording?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Adhan for \(prayer.displayName)")
                .font(.headline)
            
            ForEach(audioManager.availableRecordings, id: \.id) { recording in
                RecordingRow(
                    recording: recording,
                    isSelected: selectedRecording?.id == recording.id
                ) {
                    selectedRecording = recording
                    audioManager.setRecording(recording, for: prayer)
                }
            }
            
            HStack {
                Button("Preview") {
                    if let recording = selectedRecording {
                        Task {
                            await audioManager.playRecording(recording)
                        }
                    }
                }
                .disabled(selectedRecording == nil)
                
                Spacer()
                
                if audioManager.playbackState == .playing {
                    Button("Stop") {
                        audioManager.stop()
                    }
                }
            }
        }
        .onAppear {
            selectedRecording = audioManager.getRecordingForPrayer(prayer)
        }
    }
}

struct RecordingRow: View {
    let recording: AdhanRecording
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(recording.name)
                        .font(.body)
                        .fontWeight(isSelected ? .semibold : .regular)
                    
                    Text(recording.reciter)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(recording.style.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                        
                        Text(formatDuration(recording.duration))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}