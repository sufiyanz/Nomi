import SwiftUI
import SwiftData

@main
struct WeeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Event.self,
            PrayerTime.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var prayerTimesManager = PrayerTimesManager.shared
    @StateObject private var notificationManager = PrayerNotificationManager.shared
    @StateObject private var locationManager = LocationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    setupApp()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func setupApp() {
        // Setup notification categories
        notificationManager.setupNotificationCategories()
        
        // Request location permission for prayer times
        locationManager.requestLocationPermission()
        
        // Initialize prayer times system
        Task {
            await prayerTimesManager.initialize()
        }
    }
}
