import SwiftUI

struct VaultView: View {
    @State private var items: [VaultItem] = []
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            List(items) { item in
                VStack(alignment: .leading) {
                    Text(item.service).font(.headline)
                    Text("User: \(item.username)").font(.caption)
                    // VULNERABILITY: Parola afișată în clar
                    Text("Pass: \(item.password)").font(.system(.caption, design: .monospaced)).foregroundColor(.red)
                }
            }
            .navigationTitle("My Passwords")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) { Image(systemName: "plus") }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Logout") { NetworkService.shared.logout() }
                }
            }
            .onAppear { loadData() }
            .sheet(isPresented: $showingAddSheet) {
                AddVaultItemView(isPresented: $showingAddSheet, onAdd: loadData)
            }
        }
    }
    
    func loadData() {
        NetworkService.shared.fetchVault { items in
            if let items = items { self.items = items }
        }
    }
}

struct AddVaultItemView: View {
    @Binding var isPresented: Bool
    var onAdd: () -> Void
    @State private var service = ""
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Service", text: $service)
                TextField("Username", text: $username)
                TextField("Password", text: $password)
                Button("Save") {
                    NetworkService.shared.addVaultItem(service: service, username: username, pass: password) { success in
                        if success { DispatchQueue.main.async { onAdd(); isPresented = false } }
                    }
                }
            }
            .navigationTitle("Add Item")
        }
    }
}
