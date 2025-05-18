//
//  Question.swift
//  PDFExtract
//
//  Created by Shamam Alkafri on 14/05/2025.
//

import Foundation

struct Question: Decodable, Identifiable {
    let id = UUID()
    let type: String
    let question: String?
    let statement: String?
    let choices: [Choice]?
    let correct_answer: String?
    let is_true: Bool?
    let answer: String?
}

struct Choice: Decodable {
    let answer: String
    let correct: Bool
}
