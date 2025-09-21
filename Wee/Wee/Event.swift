import Foundation
import SwiftData

@Model
final class Event {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var notes: String?

    init(id: UUID = UUID(), title: String, startDate: Date, endDate: Date, notes: String? = nil) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
    }
}
