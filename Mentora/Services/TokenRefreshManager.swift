//
//  Serices/TokenRefreshManager.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//

import Foundation

final class TokenRefreshManager {
    static let shared = TokenRefreshManager()
    private let key = "lastRefreshDate"

    private init() {}

    func saveRefreshDate(_ date: Date = Date()) {
        UserDefaults.standard.set(date, forKey: key)
    }

    func shouldRefreshToken() -> Bool {
        guard let lastRefresh = UserDefaults.standard.object(forKey: key) as? Date else {
            return true // never refreshed before
        }

        let sixDays: TimeInterval = 6 * 24 * 60 * 60
        return Date().timeIntervalSince(lastRefresh) >= sixDays
    }
}
