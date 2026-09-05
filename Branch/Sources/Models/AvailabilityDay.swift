import Foundation
import SwiftData

@Model
final class AvailabilityDay {
    var date: Date
    var isAvailable: Bool
    var note: String

    init(
        date: Date,
        isAvailable: Bool = true,
        note: String = ""
    ) {
        self.date = Calendar.current.startOfDay(for: date)
        self.isAvailable = isAvailable
        self.note = note
    }
}
