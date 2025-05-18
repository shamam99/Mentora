//
//  SoloGameQuestion.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//

import Foundation

struct SoloGameQuestion: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let choices: [String]
}

