import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var message = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("AuthGuard Vault")
                .font(.largeTitle)
                .bold()
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: handleAction) {
                Text(isRegistering ? "Sign Up" : "Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(isRegistering ? "Back to Login" : "Create Account") {
                isRegistering.toggle()
                message = ""
            }
            .padding(.top)
            
            if !message.isEmpty {
                Text(message).foregroundColor(.red)
            }
        }
        .padding()
    }
    
    func handleAction() {
        if isRegistering {
            NetworkService.shared.register(username: username, password: password) { success, msg in
                DispatchQueue.main.async {
                    if success { isRegistering = false; message = "Account Created." }
                    else { message = msg ?? "ERROR!" }
                }
            }
        } else {
            NetworkService.shared.login(username: username, password: password) { success, msg in
                DispatchQueue.main.async {
                    if !success { message = msg ?? "LOGIN ERROR!" }
                }
            }
        }
    }
}
