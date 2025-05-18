//
//  RoomResponse.swift
//  Mentora
//
//  Created by Shamam Alkafri on 15/05/2025.
//

import Foundation


struct RoomCreateWrapper: Codable {
    let status: String
    let statusCode: Int
    let message: String
    let data: RoomResponse
}

struct RoomResponse: Codable {
    let roomId: String
    let pinCode: String?
    let status: String
    let isSolo: Bool
}
