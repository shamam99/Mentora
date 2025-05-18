//
//  MultiplayerGameViewModel.swift
//  Mentora
//
//  Created by Shamam Alkafri on 07/05/2025.
//

import Foundation
import SocketIO

final class MultiplayerGameViewModel: ObservableObject {
    private let socket: SocketIOClient
    private let userId: String

    @Published var currentQuestion: MultiplayerQuestion?
    @Published var currentIndex: Int = 0
    @Published var totalQuestions: Int = 0
    @Published var isGameOver: Bool = false
    @Published var playerScores: [String: Int] = [:]
    @Published var correctAnswer: String? = nil
    @Published var hasAnsweredCurrentQuestion = false
    @Published var selectedAnswer: String? = nil

    var onAnswerFeedback: ((String, String) -> Void)?

    init(userId: String) {
        self.userId = userId
        self.socket = SocketService.shared.getSocket()
    }

    func submitAnswer(_ answer: String) {
        guard !hasAnsweredCurrentQuestion else { return }

        hasAnsweredCurrentQuestion = true

        let payload: [String: String] = [
            "userId": userId,
            "answer": answer
        ]

        print("[GameVM] Emitting answer: \(answer)")
        socket.emit("submitMultiplayerAnswer", payload)
    }

    func setupListeners() {
        socket.off("multiplayerQuestion")
        socket.off("multiplayerAnswerResult")
        socket.off("multiplayerGameOver")

        socket.on("multiplayerQuestion") { [weak self] data, _ in
            guard let self = self else { return }

            guard
                let dict = data.first as? [String: Any],
                let index = dict["index"] as? Int,
                let total = dict["total"] as? Int,
                let questionDict = dict["question"] as? [String: Any],
                let choices = questionDict["choices"] as? [String],
                let correct = questionDict["correct"] as? String
            else {
                print("[multiplayerQuestion]  Failed to parse question")
                return
            }

            let text: String
            if let t = questionDict["text"] as? String {
                text = t
            } else if let q = questionDict["question"] as? String {
                text = q
            } else {
                text = "Untitled"
            }

            DispatchQueue.main.async {
                print("[multiplayerQuestion] ✅ Question parsed for Q\(index): \(text)")
                self.currentIndex = index
                self.totalQuestions = total
                self.currentQuestion = MultiplayerQuestion(
                    question: text,
                    choices: choices,
                    correct: correct
                )
                self.hasAnsweredCurrentQuestion = false
            }
        }


        socket.on("multiplayerAnswerResult") { [weak self] data, _ in
            guard let self = self,
                  let payload = data.first as? [String: Any],
                  let player = payload["player"] as? String,
                  let score = payload["score"] as? Int else {
                return
            }

            let correct = payload["correctAnswer"] as? String ?? "N/A"

            DispatchQueue.main.async {
                self.playerScores[player] = score
                if player == self.userId {
                    self.correctAnswer = correct
                    if let selected = self.selectedAnswer {
                        self.onAnswerFeedback?(selected, correct)
                    }
                }
                print("🧠 [GameVM] \(player)'s score: \(score), correct: \(correct)")
            }
        }

        socket.on("multiplayerGameOver") { [weak self] data, _ in
            guard let self = self,
                  let scores = data.first as? [String: Int] else { return }

            DispatchQueue.main.async {
                self.playerScores = scores
                self.isGameOver = true
                print("🏁 [GameVM] Game over. Scores: \(scores)")
            }
        }
    }

    func leaveGame() {
        print("[GameVM] Leaving game...")
        socket.emit("leaveMultiplayerGame", ["userId": userId])
        socket.removeAllHandlers()
    }
}
