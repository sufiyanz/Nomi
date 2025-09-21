import SwiftUI

struct ChoresView: View {
    var body: some View {
        NavigationStack {
            GlassEffectContainer(spacing: 20) {
                ZStack {
                    BackgroundView()
                    List {
                        ForEach(0..<5) { i in
                            HStack {
                                Text("Chore #\(i+1)")
                                Spacer()
                                Image(systemName: "circle")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(8)
                            .background(Color.clear)
                            .glassEffect(.regular, in: .rect(cornerRadius: 12))
                        }
                    }
                }
            }
            .navigationTitle("Chores")
        }
    }
}

#Preview {
    ChoresView()
}
