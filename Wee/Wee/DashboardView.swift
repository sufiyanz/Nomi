import SwiftUI
import SwiftData

struct DashboardView: View {
    @State private var now: Date = Date()
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate: Date = Date()
    @State private var events: [Event] = []

    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView {
                VStack(spacing: DesignTokens.spacing) {
                    // Welcome Message - Full width spanning two columns
                    WelcomeCard(currentTime: now)
                    
                    // Two-column layout: Prayer + Summary | Schedule
                    HStack(alignment: .top, spacing: DesignTokens.spacing) {
                        // Left Column: Prayer Time and Day Summary
                        VStack(spacing: DesignTokens.spacing) {
                            PrayerTimeCard(currentTime: now)
                            DaySummaryCard(events: dayEvents)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Right Column: Today's Schedule
                        ScheduleSectionCard(date: selectedDate, events: dayEvents)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            startClock()
            do {
                let fetched = try modelContext.fetch(FetchDescriptor<Event>())
                self.events = fetched
            } catch {
                print("Failed to fetch events: \(error)")
            }
        }
    }
    
    private var dayEvents: [Event] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: selectedDate)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return events.filter { $0.startDate < end && $0.endDate > start }
            .sorted { $0.startDate < $1.startDate }
    }

    private func startClock() {
        // Lightweight timer for live clock
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            now = Date()
        }
    }
}

// MARK: - Dashboard Cards

struct WelcomeCard: View {
    let currentTime: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(comprehensiveWelcomeMessage(for: currentTime))
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                .strokeBorder(Color.glassBorder, lineWidth: 0.5)
        )
    }
    
    private func comprehensiveWelcomeMessage(for date: Date) -> String {
        let timeGreeting = welcomeTitle(for: date)
        let dayName = dayString(date)
        let dateOrdinal = dateWithOrdinal(date)
        let monthYear = monthYearString(date)
        let currentTime = timeString(date)
        
        return "\(timeGreeting). Today is \(dayName), the \(dateOrdinal) of \(monthYear). It's \(currentTime)."
    }
    
    private func welcomeTitle(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
    
    private func dayString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    private func dateWithOrdinal(_ date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        let ordinal = ordinalSuffix(for: day)
        return "\(day)\(ordinal)"
    }
    
    private func monthYearString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func ordinalSuffix(for number: Int) -> String {
        switch number {
        case 11...13: return "th"
        default:
            switch number % 10 {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
            }
        }
    }
}

struct PrayerTimeCard: View {
    let currentTime: Date
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 8) {
                Image(systemName: "moon.stars.fill")
                    .font(.title)
                    .foregroundStyle(Color.prayerAccent)
                
                Text("Prayer")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Current Prayer")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                }
                
                Text("Maghrib")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                
                HStack {
                    Text("Next: Isha at 8:45 PM")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                .strokeBorder(Color.glassBorder, lineWidth: 0.5)
        )
    }
}

struct DaySummaryCard: View {
    let events: [Event]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundStyle(Color.summaryAccent)
                
                Text("Today's Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    SummaryItem(icon: "calendar", count: events.count, label: "Events")
                    Spacer()
                    SummaryItem(icon: "checkmark.circle", count: 3, label: "Tasks")
                    Spacer()
                    SummaryItem(icon: "clock", count: 2, label: "Free Hours")
                }
                
                Divider()
                    .opacity(0.3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Focus")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textPrimary)
                    
                    Text("No conflicts scheduled. Great day for deep work! 🚀")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                .strokeBorder(Color.glassBorder, lineWidth: 0.5)
        )
    }
}

struct SummaryItem: View {
    let icon: String
    let count: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.timeAccent)
            
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.textPrimary)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
    }
}

struct ScheduleSectionCard: View {
    let date: Date
    let events: [Event]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.day.timeline.leading")
                    .font(.title2)
                    .foregroundStyle(Color.scheduleAccent)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's Schedule")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.textPrimary)
                    
                    if events.isEmpty {
                        Text("No events scheduled")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                    } else {
                        Text("\(events.count) event\(events.count == 1 ? "" : "s") scheduled")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                
                Spacer()
                
                if !events.isEmpty {
                    Button(action: {}) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.timeAccent)
                    }
                }
            }
            
            if events.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.textSecondary.opacity(0.6))
                    
                    Text("Free Day!")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textPrimary)
                    
                    Text("No events scheduled. Perfect time for spontaneous activities or deep work.")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                DayTimelineView(date: date, events: events)
                    .frame(height: 400) // Fixed height to show full day
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                .strokeBorder(Color.glassBorder, lineWidth: 0.5)
        )
    }
}

private struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.textSecondary)
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    DashboardView()
}
