import SwiftUI
import SwiftData

struct ClientFormView: View {
    enum Mode {
        case add
        case edit(Client)
    }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    var onDelete: (() -> Void)? = nil

    @State private var companyName = ""
    @State private var contactPerson = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var address = ""
    @State private var notes = ""
    @State private var logoSystemImage = "building.2.fill"
    @State private var logoTint = "green"
    @State private var showingDeleteConfirmation = false

    private static let icons = [
        "building.2.fill", "camera.aperture", "film.fill", "bag.fill",
        "cart.fill", "paintbrush.fill", "megaphone.fill", "chart.bar.fill"
    ]
    private static let tints = ["green", "blue", "orange", "purple"]

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Company") {
                    TextField("Company name", text: $companyName)
                    TextField("Contact person", text: $contactPerson)
                }

                Section("Contact") {
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Address", text: $address)
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Logo") {
                    Picker("Icon", selection: $logoSystemImage) {
                        ForEach(Self.icons, id: \.self) { icon in
                            Image(systemName: icon).tag(icon)
                        }
                    }
                    Picker("Color", selection: $logoTint) {
                        ForEach(Self.tints, id: \.self) { tint in
                            Text(tint.capitalized).tag(tint)
                        }
                    }
                }

                if case .edit = mode {
                    Section {
                        Button("Delete Client", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                    }
                    .confirmationDialog(
                        "Delete this client? Their tasks and events will remain but become unassigned.",
                        isPresented: $showingDeleteConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Delete", role: .destructive) {
                            deleteClient()
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Client" : "New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(companyName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: loadExistingValues)
        }
    }

    private func loadExistingValues() {
        guard case .edit(let client) = mode else { return }
        companyName = client.companyName
        contactPerson = client.contactPerson
        phone = client.phone
        email = client.email
        address = client.address
        notes = client.notes
        logoSystemImage = client.logoSystemImage
        logoTint = client.logoTint
    }

    private func save() {
        switch mode {
        case .add:
            let client = Client(
                companyName: companyName,
                contactPerson: contactPerson,
                phone: phone,
                email: email,
                address: address,
                logoSystemImage: logoSystemImage,
                logoTint: logoTint,
                notes: notes
            )
            context.insert(client)
        case .edit(let client):
            client.companyName = companyName
            client.contactPerson = contactPerson
            client.phone = phone
            client.email = email
            client.address = address
            client.notes = notes
            client.logoSystemImage = logoSystemImage
            client.logoTint = logoTint
        }
        try? context.save()
        dismiss()
    }

    private func deleteClient() {
        guard case .edit(let client) = mode else { return }
        context.delete(client)
        try? context.save()
        dismiss()
        onDelete?()
    }
}

#Preview {
    ClientFormView(mode: .add)
        .modelContainer(for: Client.self, inMemory: true)
}
