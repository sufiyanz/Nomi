import SwiftUI

struct SettingsView: View {
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
