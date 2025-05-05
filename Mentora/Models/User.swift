//
//  User.swift
//  Mentora
//
//  Created by Shamam Alkafri on 04/05/2025.
//


import Foundation

struct User: Codable {
    let _id: String
    let playerId: String
    let displayName: String
    let avatarURL: String?
    let hearts: Int
}
