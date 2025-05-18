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

    init(userId: String, initialQuestionPayload: [String: Any]? = nil) {
        self.userId = userId
        self.socket = SocketService.shared.getSocket()
        self.setupListeners()

        if let payload = initialQuestionPayload {
            self.handleQuestion(payload)
        }
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
            self.handleQuestion(data.first)
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

    private func handleQuestion(_ raw: Any?) {
        guard let payload = raw as? [String: Any],
              let questionDict = payload["question"] as? [String: Any],
              let choices = questionDict["choices"] as? [String],
              let correct = questionDict["correct"] as? String,
              let text = questionDict["text"] as? String,
              let index = payload["index"] as? Int,
              let total = payload["total"] as? Int else {
            print("❌ Failed to parse multiplayerQuestion")
            return
        }

        let question = MultiplayerQuestion(question: text, choices: choices, correct: correct)

        DispatchQueue.main.async {
            self.currentQuestion = question
            self.currentIndex = index
            self.totalQuestions = total
            self.hasAnsweredCurrentQuestion = false
            self.selectedAnswer = nil
            print("✅ [GameVM] Question updated in ViewModel at index: \(index)")
        }
    }

    func leaveGame() {
        print("[GameVM] Leaving game...")
        socket.emit("leaveMultiplayerGame", ["userId": userId])
        socket.removeAllHandlers()
    }
}
