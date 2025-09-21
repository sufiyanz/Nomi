import SwiftUI

struct DayTimelineView: View {
    let date: Date
    let events: [Event]
    @State private var currentTime = Date()

    // Layout constants
    private let hourHeight: CGFloat = 60 // 60pt per hour
    private let hoursRange = 0..<24

    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                // Hour grid
                VStack(spacing: 0) {
                    ForEach(hoursRange, id: \.self) { hour in
                        HStack(alignment: .top) {
                            Text(hourLabel(hour))
                                .font(.caption)
                                .frame(width: 44, alignment: .trailing)
                                .padding(.trailing, 8)
                                .foregroundStyle(Color.textSecondary)

                            Rectangle()
                                .fill(Color.glassBorder)
                                .frame(height: 1)
                                .offset(y: -0.5)
                        }
                        .frame(height: hourHeight, alignment: .top)
                    }
                }

                // Events
                ForEach(events, id: \.id) { event in
                    eventBlock(event)
                }
                
                // Current time indicator (red line)
                if isToday {
                    currentTimeIndicator
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            startTimer()
        }
    }
    
    private var isToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    private var currentTimeIndicator: some View {
        let currentOffset = yOffset(for: currentTime)
        
        return HStack(spacing: 8) {
            // Time label
            Text(currentTimeString)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.red, in: Capsule())
                .frame(width: 52, alignment: .trailing)
            
            // Red line
            Rectangle()
                .fill(.red)
                .frame(height: 2)
                .shadow(color: .red.opacity(0.3), radius: 2, x: 0, y: 1)
            
            // Red circle indicator
            Circle()
                .fill(.red)
                .frame(width: 8, height: 8)
                .shadow(color: .red.opacity(0.5), radius: 3, x: 0, y: 1)
        }
        .offset(y: currentOffset)
        .animation(.easeInOut(duration: 0.3), value: currentOffset)
    }
    
    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: currentTime)
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            currentTime = Date()
        }
    }

    private func hourLabel(_ hour: Int) -> String {
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: self.date) ?? self.date
        let f = DateFormatter()
        f.dateFormat = "h a"
        return f.string(from: date)
    }

    private func yOffset(for date: Date) -> CGFloat {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: self.date)
        let seconds = max(0, date.timeIntervalSince(start))
        let hours = seconds / 3600.0
        return CGFloat(hours) * hourHeight
    }

    private func eventBlock(_ event: Event) -> some View {
        let yStart = yOffset(for: event.startDate)
        let yEnd = yOffset(for: event.endDate)
        let height = max(40, yEnd - yStart) // minimum height

        return VStack(alignment: .leading, spacing: 4) {
            Text(event.title)
                .font(.headline)
                .foregroundStyle(Color.textPrimary)
            Text(timeRangeString(start: event.startDate, end: event.endDate))
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(12)
        .frame(height: height, alignment: .topLeading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                .strokeBorder(Color.glassBorder, lineWidth: 0.5)
        )
        .offset(y: yStart)
        .padding(.leading, 60) // leave room for time labels
    }

    private func timeRangeString(start: Date, end: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return "\(f.string(from: start)) – \(f.string(from: end))"
    }
}

#Preview {
    // Sample preview data
    let now = Date()
    let sample = [
        Event(title: "Breakfast", startDate: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: now)!, endDate: Calendar.current.date(bySettingHour: 8, minute: 45, second: 0, of: now)!),
        Event(title: "Standup", startDate: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: now)!, endDate: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: now)!),
        Event(title: "Lunch", startDate: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: now)!, endDate: Calendar.current.date(bySettingHour: 12, minute: 45, second: 0, of: now)!),
    ]
    return DayTimelineView(date: now, events: sample)
}
