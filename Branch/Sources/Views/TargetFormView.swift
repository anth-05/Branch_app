import SwiftUI
import SwiftData

struct TargetFormView: View {
    enum Mode {
        case add
        case edit(TargetItem)
    }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let mode: Mode

    @State private var title = ""
    @State private var currentValue = ""
    @State private var goalValue = ""
    @State private var unit = ""
    @State private var hasDeadline = false
    @State private var deadline = Date()
    @State private var showingDeleteConfirmation = false

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Target title", text: $title)
                    TextField("Unit (e.g. clients, days, \u{20AC})", text: $unit)
                }

                Section("Progress") {
                    TextField("Current value", text: $currentValue)
                        .keyboardType(.decimalPad)
                    TextField("Goal value", text: $goalValue)
                        .keyboardType(.decimalPad)
                }

                Section {
                    Toggle("Deadline", isOn: $hasDeadline)
                    if hasDeadline {
                        DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    }
                }

                if case .edit(let target) = mode {
                    Section {
                        Button("Delete Target", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                    }
                    .confirmationDialog(
                        "Delete this target?",
                        isPresented: $showingDeleteConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Delete", role: .destructive) {
                            context.delete(target)
                            try? context.save()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Target" : "New Target")
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
        guard case .edit(let target) = mode else { return }
        title = target.title
        currentValue = Self.numberString(target.currentValue)
        goalValue = Self.numberString(target.goalValue)
        unit = target.unit
        if let deadlineDate = target.deadline {
            hasDeadline = true
            deadline = deadlineDate
        }
    }

    private func save() {
        let current = Double(currentValue.replacingOccurrences(of: ",", with: ".")) ?? 0
        let goal = Double(goalValue.replacingOccurrences(of: ",", with: ".")) ?? 0

        switch mode {
        case .add:
            let target = TargetItem(
                title: title,
                currentValue: current,
                goalValue: goal,
                deadline: hasDeadline ? deadline : nil,
                unit: unit
            )
            context.insert(target)
        case .edit(let target):
            target.title = title
            target.currentValue = current
            target.goalValue = goal
            target.deadline = hasDeadline ? deadline : nil
            target.unit = unit
        }
        try? context.save()
        dismiss()
    }

    private static func numberString(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(value)
    }
}
