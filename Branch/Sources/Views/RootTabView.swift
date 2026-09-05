import SwiftUI

struct RootTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.background)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            PlannerView()
                .tabItem { Label("Planner", systemImage: "calendar") }

            ClientsListView()
                .tabItem { Label("Clients", systemImage: "person.2.fill") }

            TasksView()
                .tabItem { Label("Tasks", systemImage: "checklist") }

            AvailabilityView()
                .tabItem { Label("Availability", systemImage: "video.fill") }

            TargetsView()
                .tabItem { Label("Targets", systemImage: "target") }
        }
        .tint(Theme.accent)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: Client.self, inMemory: true)
}
