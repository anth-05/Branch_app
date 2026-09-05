import Foundation
import SwiftData

enum AvailabilityMaintenance {
    /// Makes sure every day in the next 30 days has an AvailabilityDay entry, so the
    /// Availability tab always has something to show/edit going forward.
    static func ensureUpcomingAvailability(context: ModelContext, daysAhead: Int = 30) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let existing = (try? context.fetch(FetchDescriptor<AvailabilityDay>())) ?? []
        let existingDates = Set(existing.map { calendar.startOfDay(for: $0.date) })

        for offset in 0..<daysAhead {
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            guard !existingDates.contains(date) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            let isWeekend = weekday == 1 || weekday == 7
            context.insert(AvailabilityDay(date: date, isAvailable: !isWeekend))
        }
        try? context.save()
    }
}
