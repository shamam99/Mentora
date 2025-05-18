//
//  AuthViewModel.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//

import Foundation

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var token: String?
    @Published var error: String?

    init() {
        loadFromKeychain()
        
    }
    
    func tryAutoLogin() {
        if let token = KeychainManager.shared.getToken() {
            self.token = token
            APIManager.shared.fetchUserProfile(using: token) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        self.user = user
                        self.refreshTokenIfNeeded() 
                    case .failure(let error):
                        self.error = "Token invalid or expired: \(error.localizedDescription)"
                        KeychainManager.shared.clearToken()
                    }
                }
            }
        }
    }

    func loadFromKeychain() {
        if let savedToken = KeychainManager.shared.getToken() {
            // verify it with an endpoint like /user/me
            self.token = savedToken
        }
    }

    func login() {
        GameCenterManager.shared.getSignaturePayload { result in
            switch result {
            case .success(let payload):
                APIManager.shared.loginWithGameCenter(payload: payload) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let (user, token)):
                            self.user = user
                            self.token = token
                            KeychainManager.shared.saveToken(token)
                            self.error = nil
                        case .failure(let error):
                            self.error = error.localizedDescription
                            print(" Login decoding failed: \(error.localizedDescription)")
                        }
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    print(" Signature generation failed: \(error.localizedDescription)")
                }
            }
        }
    }

    func logout() {
        user = nil
        token = nil
        KeychainManager.shared.clearToken()
    }
    
    func refreshTokenIfNeeded() {
        guard let token = token else { return }
        
        if TokenRefreshManager.shared.shouldRefreshToken() {
            // Call refresh token endpoint
            guard let url = URL(string: "http://192.168.8.153:3001/auth/refresh-token") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Refresh failed:", error.localizedDescription)
                    return
                }

                guard let data = data else { return }

                do {
                    let decoded = try JSONDecoder().decode(AuthResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.token = decoded.data.token
                        self.user = decoded.data.user
                        KeychainManager.shared.saveToken(decoded.data.token)
                        TokenRefreshManager.shared.saveRefreshDate()
                        print("Token successfully refreshed")
                    }
                } catch {
                    print("Decode refresh error:", error.localizedDescription)
                }
            }.resume()
        } else {
            print("Token refresh not needed yet")
        }
    }
}
