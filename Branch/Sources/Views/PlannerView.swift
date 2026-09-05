import SwiftUI
import SwiftData

struct PlannerView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \PlannerEvent.date) private var events: [PlannerEvent]
    @State private var selectedDate = Date()
    @State private var showingAddEvent = false
    @State private var editingEvent: PlannerEvent?

    private var eventsOnSelectedDate: [PlannerEvent] {
        events.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var upcomingEvents: [PlannerEvent] {
        events.filter { $0.date >= Calendar.current.startOfDay(for: Date()) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DatePicker("Selected date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .tint(Theme.accent)
                        .colorScheme(.dark)
                }
                .listRowBackground(Theme.card)

                Section("Events on \(selectedDate.formatted(date: .abbreviated, time: .omitted))") {
                    if eventsOnSelectedDate.isEmpty {
                        Text("No events")
                            .foregroundStyle(Theme.textSecondary)
                    } else {
                        ForEach(eventsOnSelectedDate) { event in
                            EventRow(event: event)
                                .contentShape(Rectangle())
                                .onTapGesture { editingEvent = event }
                        }
                        .onDelete { deleteEvents(eventsOnSelectedDate, at: $0) }
                    }
                }
                .listRowBackground(Theme.card)

                Section("Upcoming") {
                    ForEach(upcomingEvents) { event in
                        EventRow(event: event)
                            .contentShape(Rectangle())
                            .onTapGesture { editingEvent = event }
                    }
                    .onDelete { deleteEvents(upcomingEvents, at: $0) }
                }
                .listRowBackground(Theme.card)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Planner")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                EventFormView(mode: .add(presetDate: selectedDate))
            }
            .sheet(item: $editingEvent) { event in
                EventFormView(mode: .edit(event))
            }
        }
    }

    private func deleteEvents(_ list: [PlannerEvent], at offsets: IndexSet) {
        for index in offsets {
            context.delete(list[index])
        }
        try? context.save()
    }
}

private struct EventRow: View {
    let event: PlannerEvent

    var body: some View {
        HStack(spacing: 12) {
            if let client = event.client {
                ClientLogoView(client: client, size: 32)
            } else {
                Image(systemName: "calendar")
                    .foregroundStyle(Theme.textSecondary)
                    .frame(width: 32, height: 32)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .foregroundStyle(Theme.textPrimary)
                Text(event.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }
}

#Preview {
    PlannerView()
        .modelContainer(for: PlannerEvent.self, inMemory: true)
}
