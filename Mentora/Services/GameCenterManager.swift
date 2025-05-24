//
//  GameCenterManager.swift
//  Mentora
//
//  Created by Shamam Alkafri on 04/05/2025.
//

import Foundation
import GameKit
import UIKit

class GameCenterManager: ObservableObject {
    static let shared = GameCenterManager()
    @Published var isAuthenticated = false

    private init() {
        authenticateUser()
    }

    func authenticateUser(completion: @escaping (Bool) -> Void = { _ in }) {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let vc = viewController {
                if let root = UIApplication.shared.windows.first?.rootViewController {
                    root.present(vc, animated: true) {
                        // Wait for UI result
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                            completion(self.isAuthenticated)
                        }
                    }
                }
            } else if GKLocalPlayer.local.isAuthenticated {
                self.isAuthenticated = true
                completion(true)
            } else {
                self.isAuthenticated = false
                print("Game Center error: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
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
    
    func reportAchievement(id: String, percent: Double = 100.0) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Game Center not authenticated")
            return
        }

        let achievement = GKAchievement(identifier: id)
        achievement.percentComplete = percent
        achievement.showsCompletionBanner = true

        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("Failed to report achievement: \(error.localizedDescription)")
            } else {
                print("Achievement \(id) reported")
            }
        }
    }

}
