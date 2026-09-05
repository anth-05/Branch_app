import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var context
    @Query private var allTasks: [TaskItem]
    @State private var showDoneTasks = true
    @State private var showingAddTask = false
    @State private var editingTask: TaskItem?

    private var visibleTasks: [TaskItem] {
        let sorted = allTasks.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        return showDoneTasks ? sorted : sorted.filter { !$0.isDone }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(visibleTasks) { task in
                    TaskRow(task: task) {
                        editingTask = task
                    }
                    .listRowBackground(Theme.card)
                }
                .onDelete(perform: deleteTasks)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDoneTasks.toggle()
                    } label: {
                        Image(systemName: showDoneTasks ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                TaskFormView(mode: .add(presetClient: nil))
            }
            .sheet(item: $editingTask) { task in
                TaskFormView(mode: .edit(task))
            }
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = visibleTasks[index]
            NotificationManager.cancelReminder(for: task)
            context.delete(task)
        }
        try? context.save()
    }
}

#Preview {
    TasksView()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
