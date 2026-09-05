import SwiftUI
import SwiftData

@main
struct BranchApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([
            Client.self,
            TaskItem.self,
            TargetItem.self,
            PlannerEvent.self,
            AvailabilityDay.self
        ])
        do {
            container = try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        SampleDataSeeder.seedIfNeeded(context: container.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(container)
    }
}
