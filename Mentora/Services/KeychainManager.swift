//
//  KeychainManager.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//

import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    private let service = "com.mentora.auth"
    private let account = "jwt_token"

    private init() {}

    // Save token to Keychain
    func saveToken(_ token: String) {
        guard let tokenData = token.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: tokenData
        ]

        SecItemDelete(query as CFDictionary) // Remove old token if exists
        SecItemAdd(query as CFDictionary, nil)
    }

    // Load token from Keychain
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let data = result as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        }

        return nil
    }

    // Clear token from Keychain
    func clearToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
