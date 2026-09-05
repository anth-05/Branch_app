import SwiftUI
import SwiftData

struct AvailabilityView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \AvailabilityDay.date) private var days: [AvailabilityDay]

    private var availableCount: Int {
        days.filter(\.isAvailable).count
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Next \(days.count) days")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                            Spacer()
                            Text("\(availableCount) open for video")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Theme.accent)
                        }

                        DotGrid(days: days)
                    }
                    .brandCard()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section {
                    ForEach(days) { day in
                        AvailabilityRow(day: day)
                            .listRowBackground(Theme.card)
                    }
                } header: {
                    Text("Mark days your team is free to shoot video with clients")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Availability")
            .onAppear {
                SampleDataSeeder.ensureUpcomingAvailability(context: context)
            }
        }
    }
}

private struct AvailabilityRow: View {
    @Bindable var day: AvailabilityDay

    var body: some View {
        Toggle(isOn: $day.isAvailable) {
            VStack(alignment: .leading, spacing: 2) {
                Text(day.date, format: .dateTime.weekday(.wide).day().month())
                    .foregroundStyle(Theme.textPrimary)
                if !day.note.isEmpty {
                    Text(day.note)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .tint(Theme.accent)
    }
}

private struct DotGrid: View {
    let days: [AvailabilityDay]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(days) { day in
                Circle()
                    .fill(day.isAvailable ? Theme.accent : Theme.cardSecondary)
                    .frame(width: 10, height: 10)
            }
        }
    }
}

#Preview {
    AvailabilityView()
        .modelContainer(for: AvailabilityDay.self, inMemory: true)
}
