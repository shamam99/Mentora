//
//  MultiplayerGameViewModel.swift
//  Mentora
//
//  Created by Shamam Alkafri on 07/05/2025.
//


import Foundation
import SocketIO
import Combine

final class MultiplayerGameViewModel: ObservableObject {
    private let socket: SocketIOClient
    private let userId: String

    @Published var currentQuestion: MultiplayerQuestion?
    @Published var currentIndex: Int = 0
    @Published var totalQuestions: Int = 0
    @Published var isGameOver: Bool = false
    @Published var playerScores: [String: Int] = [:]

    init(userId: String) {
        self.userId = userId
        self.socket = SocketService.shared.getSocket()
        setupListeners()
    }

    func submitAnswer(_ answer: String) {
        let payload: [String: String] = [
            "userId": userId,
            "answer": answer
        ]
        print("[GameVM] Emitting answer: \(answer)")
        socket.emit("submitMultiplayerAnswer", payload)
    }

    private func setupListeners() {
        socket.off("multiplayerQuestion")
        socket.off("multiplayerAnswerResult")
        socket.off("multiplayerGameOver")

        socket.on("multiplayerQuestion") { [weak self] data, _ in
            guard let self = self,
                  let payload = data.first as? [String: Any],
                  let index = payload["index"] as? Int,
                  let total = payload["total"] as? Int,
                  let questionDict = payload["question"] as? [String: Any],
                  let choices = questionDict["choices"] as? [String],
                  let text = questionDict["text"] as? String ?? questionDict["questionText"] as? String else {
                print(" [GameVM] Invalid question payload")
                return
            }

            DispatchQueue.main.async {
                self.currentQuestion = MultiplayerQuestion(text: text, choices: choices)
                self.currentIndex = index
                self.totalQuestions = total
                print(" [GameVM] Q\(index)/\(total): \(text)")
            }
        }

        socket.on("multiplayerAnswerResult") { [weak self] data, _ in
            guard let self = self,
                  let payload = data.first as? [String: Any],
                  let player = payload["player"] as? String,
                  let score = payload["score"] as? Int else { return }

            DispatchQueue.main.async {
                self.playerScores[player] = score
                print(" [GameVM] \(player)'s score updated to \(score)")
            }
        }

        socket.on("multiplayerGameOver") { [weak self] data, _ in
            guard let self = self,
                  let scores = data.first as? [String: Int] else { return }

            DispatchQueue.main.async {
                self.playerScores = scores
                self.isGameOver = true
                print(" [GameVM] Game over. Final scores: \(scores)")
            }
        }
    }
    
    func leaveGame() {
        print("[GameVM] Leaving game...")
        socket.emit("leaveMultiplayerGame", ["userId": userId])
        socket.removeAllHandlers()
    }
}
