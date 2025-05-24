//
//  Achievement.swift
//  Mentora
//
//  Created by Shamam Alkafri on 19/05/2025.
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    var iconName: String
    var isUnlocked: Bool
}

struct AchievementResponseWrapper: Codable {
    let data: AchievementList
}

struct AchievementList: Codable {
    let achievements: [Achievement]
}
