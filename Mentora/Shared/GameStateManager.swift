//
//  GameStateManager.swift
//  Mentora
//
//  Created by Shamam Alkafri on 18/05/2025.
//

import Foundation

class GameStateManager: ObservableObject {
    static let shared = GameStateManager()

    @Published var multiplayerQuestion: MultiplayerQuestion?
    @Published var multiplayerQuestionIndex: Int = 0
    @Published var multiplayerQuestionTotal: Int = 0

    private init() {}
}
