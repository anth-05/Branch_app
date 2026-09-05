import Foundation
import SwiftData

enum SampleDataSeeder {
    static func seedIfNeeded(context: ModelContext) {
        let existingClients = try? context.fetch(FetchDescriptor<Client>())
        guard (existingClients?.isEmpty ?? true) else {
            ensureUpcomingAvailability(context: context)
            return
        }

        let calendar = Calendar.current
        let today = Date()

        let acme = Client(
            companyName: "Acme Studios",
            contactPerson: "Lotte de Vries",
            phone: "+31 6 1234 5678",
            email: "lotte@acmestudios.nl",
            address: "Keizersgracht 100, Amsterdam",
            logoSystemImage: "camera.aperture",
            logoTint: "orange"
        )
        let noord = Client(
            companyName: "Noord Media",
            contactPerson: "Sven Bakker",
            phone: "+31 6 9876 5432",
            email: "sven@noordmedia.nl",
            address: "Coolsingel 42, Rotterdam",
            logoSystemImage: "film.fill",
            logoTint: "blue"
        )
        let horizon = Client(
            companyName: "Horizon Retail",
            contactPerson: "Fenna Jansen",
            phone: "+31 6 5544 3322",
            email: "fenna@horizonretail.nl",
            address: "Grote Markt 5, Utrecht",
            logoSystemImage: "bag.fill",
            logoTint: "purple"
        )

        [acme, noord, horizon].forEach { context.insert($0) }

        context.insert(TaskItem(title: "Send Q3 proposal", dueDate: calendar.date(byAdding: .day, value: 1, to: today), client: acme))
        context.insert(TaskItem(title: "Edit highlight reel", dueDate: calendar.date(byAdding: .day, value: 3, to: today), client: noord))
        context.insert(TaskItem(title: "Follow up on invoice", dueDate: calendar.date(byAdding: .day, value: -1, to: today), isDone: true, client: horizon))
        context.insert(TaskItem(title: "Update team calendar", dueDate: calendar.date(byAdding: .day, value: 2, to: today)))

        context.insert(TargetItem(title: "New clients this quarter", currentValue: 3, goalValue: 5, deadline: calendar.date(byAdding: .month, value: 1, to: today), unit: "clients"))
        context.insert(TargetItem(title: "Video days booked", currentValue: 8, goalValue: 12, deadline: calendar.date(byAdding: .month, value: 1, to: today), unit: "days"))
        context.insert(TargetItem(title: "Monthly revenue", currentValue: 18500, goalValue: 25000, deadline: calendar.date(byAdding: .month, value: 1, to: today), unit: "\u{20AC}"))

        context.insert(PlannerEvent(title: "Shoot: Acme campaign", date: calendar.date(byAdding: .day, value: 2, to: today) ?? today, client: acme))
        context.insert(PlannerEvent(title: "Client call: Noord Media", date: calendar.date(byAdding: .day, value: 4, to: today) ?? today, client: noord))
        context.insert(PlannerEvent(title: "Internal planning", date: calendar.date(byAdding: .day, value: 5, to: today) ?? today))

        ensureUpcomingAvailability(context: context)

        try? context.save()
    }

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
