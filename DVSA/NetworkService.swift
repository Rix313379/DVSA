import Foundation
import SwiftUI
import Combine

// --- DATA MODELS ---
struct VaultItem: Codable, Identifiable {
    let id: Int
    let service: String
    let username: String
    let password: String
}

struct VaultResponse: Codable {
    let vault: [VaultItem]
}

struct TokenResponse: Codable {
    let token: String
}

// --- NETWORK SERVICE ---
class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    // URL Backend: 127.0.0.1 pentru Simulator.
    // Dacă testezi pe telefon, pune IP-ul laptopului (ex: http://192.168.1.x:5001)
    let baseURL = "http://127.0.0.1:5001"
    
    @Published var isAuthenticated = false
    
    private init() {
        if UserDefaults.standard.string(forKey: "authToken") != nil {
            self.isAuthenticated = true
        }
    }
    
    var token: String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    // LOGIN
    func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/login") else { return }
        let body: [String: Any] = ["username": username, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { completion(false, "Eroare conexiune"); return }
            
            if let decoded = try? JSONDecoder().decode(TokenResponse.self, from: data) {
                DispatchQueue.main.async {
                    UserDefaults.standard.set(decoded.token, forKey: "authToken")
                    self.isAuthenticated = true
                    completion(true, nil)
                }
            } else {
                completion(false, "Date incorecte")
            }
        }.resume()
    }
    
    // REGISTER
    func register(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/register") else { return }
        let body: [String: Any] = ["username": username, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true, "Cont creat!")
            } else {
                completion(false, "Eroare creare.")
            }
        }.resume()
    }
    
    // LOGOUT
    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        self.isAuthenticated = false
    }
    
    // GET VAULT
    func fetchVault(completion: @escaping ([VaultItem]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/vault"), let token = self.token else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { completion(nil); return }
            if let decoded = try? JSONDecoder().decode(VaultResponse.self, from: data) {
                DispatchQueue.main.async { completion(decoded.vault) }
            } else { completion(nil) }
        }.resume()
    }
    
    // ADD ITEM
    func addVaultItem(service: String, username: String, pass: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/vault"), let token = self.token else { return }
        let body: [String: Any] = ["service": service, "username": username, "password": pass]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else { completion(false) }
        }.resume()
    }
}
