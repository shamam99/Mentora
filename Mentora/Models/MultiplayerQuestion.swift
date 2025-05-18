//
//  MultiplayerQuestion.swift
//  Mentora
//
//  Created by Shamam Alkafri on 07/05/2025.
//


import Foundation

struct MultiplayerQuestion: Codable {
    let question: String
    let choices: [String]
    let correct: String
}
