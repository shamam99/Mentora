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
}
