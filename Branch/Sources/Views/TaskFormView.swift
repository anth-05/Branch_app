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
    @State private var hasReminder = false
    @State private var reminderDate = Date()
    @State private var selectedClient: Client?
    @State private var showingDeleteConfirmation = false

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

                Section {
                    Toggle("Remind me", isOn: $hasReminder)
                    if hasReminder {
                        DatePicker("Reminder", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    }
                } footer: {
                    Text("Sends a notification to this device at the chosen time.")
                }

                Section("Client") {
                    Picker("Client", selection: $selectedClient) {
                        Text("None").tag(Client?.none)
                        ForEach(clients) { client in
                            Text(client.companyName).tag(Optional(client))
                        }
                    }
                }

                if case .edit(let task) = mode {
                    Section {
                        Button("Delete Task", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                    }
                    .confirmationDialog(
                        "Delete this task?",
                        isPresented: $showingDeleteConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Delete", role: .destructive) {
                            deleteTask(task)
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
            if let reminder = task.reminderDate {
                hasReminder = true
                reminderDate = reminder
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
                client: selectedClient,
                reminderDate: hasReminder ? reminderDate : nil
            )
            context.insert(task)
            try? context.save()
            if hasReminder {
                NotificationManager.scheduleReminder(for: task)
            }
        case .edit(let task):
            task.title = title
            task.dueDate = hasDueDate ? dueDate : nil
            task.reminderDate = hasReminder ? reminderDate : nil
            task.client = selectedClient
            try? context.save()
            if hasReminder {
                NotificationManager.scheduleReminder(for: task)
            } else {
                NotificationManager.cancelReminder(for: task)
            }
        }
        dismiss()
    }

    private func deleteTask(_ task: TaskItem) {
        NotificationManager.cancelReminder(for: task)
        context.delete(task)
        try? context.save()
        dismiss()
    }
}
