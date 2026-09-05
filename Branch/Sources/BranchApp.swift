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
            // The on-disk store doesn't match the current model schema (e.g. after
            // adding a new required field during development) and can't be
            // lightweight-migrated. Reset the store rather than crashing.
            Self.deleteExistingStore()
            do {
                container = try ModelContainer(for: schema)
            } catch {
                fatalError("Failed to create ModelContainer even after resetting the store: \(error)")
            }
        }
        SampleDataSeeder.seedIfNeeded(context: container.mainContext)
        NotificationManager.requestAuthorizationIfNeeded()
    }

    private static func deleteExistingStore() {
        guard let appSupport = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else { return }

        for suffix in ["", "-wal", "-shm"] {
            let url = appSupport.appendingPathComponent("default.store\(suffix)")
            try? FileManager.default.removeItem(at: url)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(container)
    }
}
