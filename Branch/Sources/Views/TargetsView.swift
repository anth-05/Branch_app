import SwiftUI
import SwiftData

struct TargetsView: View {
    @Environment(\.modelContext) private var context
    @Query private var targets: [TargetItem]
    @State private var showingAddTarget = false
    @State private var editingTarget: TargetItem?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(targets) { target in
                        TargetCard(target: target)
                            .onTapGesture { editingTarget = target }
                            .contextMenu {
                                Button(role: .destructive) {
                                    delete(target)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle("Targets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTarget = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTarget) {
                TargetFormView(mode: .add)
            }
            .sheet(item: $editingTarget) { target in
                TargetFormView(mode: .edit(target))
            }
        }
    }

    private func delete(_ target: TargetItem) {
        context.delete(target)
        try? context.save()
    }
}

private struct TargetCard: View {
    let target: TargetItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(target.title)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
                Spacer()
            }

            (
                Text(valueString)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                + Text(" " + target.unit)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
            )

            ProgressView(value: target.progress)
                .tint(Theme.accent)

            if let deadline = target.deadline {
                Text("by \(deadline.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .brandCard()
    }

    private var valueString: String {
        let value = target.currentValue
        let formatted = value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
        return target.unit == "\u{20AC}" ? "\u{20AC}\(formatted)" : formatted
    }
}

#Preview {
    TargetsView()
        .modelContainer(for: TargetItem.self, inMemory: true)
}
