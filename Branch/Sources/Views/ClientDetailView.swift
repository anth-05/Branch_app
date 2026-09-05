import SwiftUI
import SwiftData

struct ClientDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var client: Client
    @State private var showingEditClient = false
    @State private var showingAddTask = false
    @State private var editingTask: TaskItem?

    private var clientTasks: [TaskItem] {
        client.tasks.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    ClientLogoView(client: client, size: 64)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(client.companyName)
                            .font(.title3.bold())
                            .foregroundStyle(Theme.textPrimary)
                        Text(client.contactPerson)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding(.vertical, 6)
            }
            .listRowBackground(Theme.card)

            Section("Contact") {
                Label(client.phone, systemImage: "phone.fill")
                Label(client.email, systemImage: "envelope.fill")
                Label(client.address, systemImage: "mappin.and.ellipse")
            }
            .foregroundStyle(Theme.textPrimary)
            .listRowBackground(Theme.card)

            if !client.notes.isEmpty {
                Section("Notes") {
                    Text(client.notes)
                        .foregroundStyle(Theme.textPrimary)
                }
                .listRowBackground(Theme.card)
            }

            Section("Tasks for \(client.companyName)") {
                if clientTasks.isEmpty {
                    Text("No tasks yet")
                        .foregroundStyle(Theme.textSecondary)
                } else {
                    ForEach(clientTasks) { task in
                        TaskRow(task: task) {
                            editingTask = task
                        }
                    }
                }
                Button {
                    showingAddTask = true
                } label: {
                    Label("Add task", systemImage: "plus.circle.fill")
                }
                .foregroundStyle(Theme.accent)
            }
            .listRowBackground(Theme.card)
        }
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .navigationTitle(client.companyName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditClient = true
                }
            }
        }
        .sheet(isPresented: $showingEditClient) {
            ClientFormView(mode: .edit(client), onDelete: { dismiss() })
        }
        .sheet(isPresented: $showingAddTask) {
            TaskFormView(mode: .add(presetClient: client))
        }
        .sheet(item: $editingTask) { task in
            TaskFormView(mode: .edit(task))
        }
    }
}
