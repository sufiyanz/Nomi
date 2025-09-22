import SwiftUI
import CoreLocation

struct SettingsView: View {
    @StateObject private var locationManager = LocationManager.shared
    
    private var locationPermissionStatusText: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "Not Requested"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .authorizedWhenInUse:
            return "Authorized"
        case .authorizedAlways:
            return "Always Authorized"
        @unknown default:
            return "Unknown"
        }
    }
    
    private var locationPermissionStatusColor: Color {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return .orange
        case .denied, .restricted:
            return .red
        case .authorizedWhenInUse, .authorizedAlways:
            return .green
        @unknown default:
            return .gray
        }
    }
    
    var body: some View {
        NavigationStack {
            GlassEffectContainer(spacing: 20) {
                ZStack {
                    BackgroundView()
                    Form {
                        Section("Access") {
                            Toggle("Parent Mode (temporary)", isOn: .constant(true))
                        }
                        Section("Theme") {
                            Picker("Appearance", selection: .constant(0)) {
                                Text("System").tag(0)
                                Text("Light").tag(1)
                                Text("Dark").tag(2)
                            }
                        }
                        
                        Section("Location Services") {
                            HStack {
                                Text("Location Permission")
                                Spacer()
                                Text(locationPermissionStatusText)
                                    .foregroundColor(locationPermissionStatusColor)
                            }
                            
                            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .notDetermined {
                                Button("Request Location Permission") {
                                    Task {
                                        locationManager.requestLocationPermission()
                                    }
                                }
                                .foregroundColor(.blue)
                            }
                            
                            if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                                Button("Refresh Location") {
                                    Task {
                                        do {
                                            _ = try await locationManager.getCurrentLocation()
                                        } catch {
                                            print("Failed to get location: \(error)")
                                        }
                                    }
                                }
                                .foregroundColor(.blue)
                                .disabled(locationManager.isLoading)
                                
                                if locationManager.isLoading {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Getting location...")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        
                        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                            Section("Current Location") {
                                if let prayerLocation = locationManager.currentPrayerLocation {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("City:")
                                            Spacer()
                                            Text(prayerLocation.city ?? "Unknown")
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        HStack {
                                            Text("Country:")
                                            Spacer()
                                            Text(prayerLocation.country ?? "Unknown")
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        HStack {
                                            Text("Coordinates:")
                                            Spacer()
                                            Text("\(String(format: "%.4f", prayerLocation.latitude)), \(String(format: "%.4f", prayerLocation.longitude))")
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        HStack {
                                            Text("Timezone:")
                                            Spacer()
                                            Text(prayerLocation.timezone ?? "Unknown")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                } else if locationManager.currentLocation != nil {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Loading location details...")
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    Text("Location not available")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
