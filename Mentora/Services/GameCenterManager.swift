import Foundation
import GameKit
import UIKit

class GameCenterManager: ObservableObject {
    static let shared = GameCenterManager()
    @Published var isAuthenticated = false

    private init() {
        authenticateUser()
    }

    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let vc = viewController {
                if let root = UIApplication.shared.windows.first?.rootViewController {
                    root.present(vc, animated: true, completion: nil)
                }
            } else if GKLocalPlayer.local.isAuthenticated {
                self.isAuthenticated = true
                print(" Game Center Authenticated")
            } else {
                self.isAuthenticated = false
                print(" Game Center failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func getSignaturePayload(completion: @escaping (Result<[String: String], Error>) -> Void) {
        guard isAuthenticated else {
            return completion(.failure(NSError(domain: "GameCenter", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        }

        GKLocalPlayer.local.generateIdentityVerificationSignature { url, signature, salt, timestamp, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let url = url,
                  let signature = signature,
                  let salt = salt else {
                return completion(.failure(NSError(domain: "GameCenter", code: 500, userInfo: [NSLocalizedDescriptionKey: "Missing signature data"])))
            }

            let displayName = GKLocalPlayer.local.alias  // match backend 

            let payload: [String: String] = [
                "playerId": GKLocalPlayer.local.playerID,
                "displayName": displayName,
                "publicKeyUrl": url.absoluteString,
                "signature": signature.base64EncodedString(),
                "salt": salt.base64EncodedString(),
                "timestamp": String(timestamp)
            ]

            completion(.success(payload))
        }
    }
}
