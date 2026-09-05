import SwiftUI
import SwiftData

struct ClientsListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Client.companyName) private var clients: [Client]
    @State private var searchText = ""
    @State private var showingAddClient = false

    private var filteredClients: [Client] {
        guard !searchText.isEmpty else { return clients }
        return clients.filter {
            $0.companyName.localizedCaseInsensitiveContains(searchText) ||
            $0.contactPerson.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredClients) { client in
                    NavigationLink(value: client) {
                        HStack(spacing: 14) {
                            ClientLogoView(client: client)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(client.companyName)
                                    .font(.headline)
                                    .foregroundStyle(Theme.textPrimary)
                                Text(client.phone)
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Theme.card)
                }
                .onDelete(perform: deleteClients)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .searchable(text: $searchText, prompt: "Search clients")
            .navigationTitle("Clients")
            .navigationDestination(for: Client.self) { client in
                ClientDetailView(client: client)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddClient = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                ClientFormView(mode: .add)
            }
        }
    }

    private func deleteClients(at offsets: IndexSet) {
        for index in offsets {
            context.delete(filteredClients[index])
        }
        try? context.save()
    }
}

#Preview {
    ClientsListView()
        .modelContainer(for: Client.self, inMemory: true)
}
