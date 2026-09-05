import SwiftUI
import SwiftData

struct TaskFormView: View {
    enum Mode {
        case add(presetClient: Client?)
        case edit(TaskItem)
    }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Client.companyName) private var clients: [Client]

    let mode: Mode

    @State private var title = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var selectedClient: Client?

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task title", text: $title)
                }

                Section {
                    Toggle("Due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due", selection: $dueDate, displayedComponents: .date)
                    }
                }

                Section("Client") {
                    Picker("Client", selection: $selectedClient) {
                        Text("None").tag(Client?.none)
                        ForEach(clients) { client in
                            Text(client.companyName).tag(Optional(client))
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
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
        case .add(let presetClient):
            selectedClient = presetClient
        case .edit(let task):
            title = task.title
            if let due = task.dueDate {
                hasDueDate = true
                dueDate = due
            }
            selectedClient = task.client
        }
    }

    private func save() {
        switch mode {
        case .add:
            let task = TaskItem(
                title: title,
                dueDate: hasDueDate ? dueDate : nil,
                client: selectedClient
            )
            context.insert(task)
        case .edit(let task):
            task.title = title
            task.dueDate = hasDueDate ? dueDate : nil
            task.client = selectedClient
        }
        try? context.save()
        dismiss()
    }
}
