//
//  AuthResponse.swift
//  Mentora
//
//  Created by Shamam Alkafri on 04/05/2025.
//

import Foundation


struct AuthResponse: Codable {
    let status: String
    let statusCode: Int
    let message: String
    let data: AuthData
}

struct AuthData: Codable {
    let user: User
    let token: String
}


