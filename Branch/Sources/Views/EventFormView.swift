import SwiftUI
import SwiftData

struct EventFormView: View {
    enum Mode {
        case add(presetDate: Date)
        case edit(PlannerEvent)
    }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Client.companyName) private var clients: [Client]

    let mode: Mode

    @State private var title = ""
    @State private var date = Date()
    @State private var notes = ""
    @State private var selectedClient: Client?

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Event title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Client") {
                    Picker("Client", selection: $selectedClient) {
                        Text("None").tag(Client?.none)
                        ForEach(clients) { client in
                            Text(client.companyName).tag(Optional(client))
                        }
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Event" : "New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: loadExistingValues)
        }
    }

    private func loadExistingValues() {
        switch mode {
        case .add(let presetDate):
            date = presetDate
        case .edit(let event):
            title = event.title
            date = event.date
            notes = event.notes
            selectedClient = event.client
        }
    }

    private func save() {
        switch mode {
        case .add:
            let event = PlannerEvent(title: title, date: date, notes: notes, client: selectedClient)
            context.insert(event)
        case .edit(let event):
            event.title = title
            event.date = date
            event.notes = notes
            event.client = selectedClient
        }
        try? context.save()
        dismiss()
    }
}
