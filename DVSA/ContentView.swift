import SwiftUI

struct ContentView: View {
    // Ascultăm starea autentificării
    @ObservedObject var networkService = NetworkService.shared
    
    var body: some View {
        Group {
            if networkService.isAuthenticated {
                VaultView()
                    .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
    }
}
