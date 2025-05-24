//
//  MultiplayerGameViewModel.swift
//  Mentora
//
//  Created by Shamam Alkafri on 07/05/2025.
//

import Foundation
import SocketIO
import SwiftUI

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
    @Published var finalResults: [PlayerResult] = []
    @Published var showResults: Bool = false
    @Published var isInMultiplayerGame: Bool = false
    @Published var playersInRoom: [String] = [] // Filled during join/start
    @Published var answeredPlayers: Set<String> = [] // Track who answered



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
                // ✅ Add player to answered list
                self.answeredPlayers.insert(player)

                // ✅ Update score
                self.playerScores[player] = score

                // ✅ If it's this player's answer, show feedback
                if player == self.userId {
                    self.correctAnswer = correct
                    if let selected = self.selectedAnswer {
                        self.onAnswerFeedback?(selected, correct)
                        if selected == correct {
                            SoundPlayer.shared.playSound(named: "4")
                        } else {
                            SoundPlayer.shared.playSound(named: "5")
                        }
                    }
                }
                print("🧠 [GameVM] \(player)'s score: \(score), correct: \(correct)")
            }
        }

        socket.on("multiplayerGameOver") { [weak self] data, _ in
            guard let self = self,
                  let payload = data.first as? [String: [String: Any]] else { return }

            DispatchQueue.main.async {
                var tempScores: [String: Int] = [:]
                var players: [(id: String, displayName: String, score: Int)] = []

                for (uid, entry) in payload {
                    let displayName = entry["displayName"] as? String ?? "Player"
                    let score = entry["score"] as? Int ?? 0
                    tempScores[uid] = score
                    players.append((uid, displayName, score))
                }

                self.playerScores = tempScores
                self.isGameOver = true
                print("🏁 [GameVM] Game over. Scores: \(tempScores)")

                let sorted = players.sorted { $0.score > $1.score }

                let mapped = sorted.enumerated().map { (index, entry) -> PlayerResult in
                    let podiumColorHex: String
                    let image: String

                    switch index {
                    case 0:
                        image = "PlayerOrange"
                        podiumColorHex = "#F67348"
                    case 1:
                        image = "PlayerPink"
                        podiumColorHex = "#F9A7F9"
                    case 2:
                        image = "PlayerPurple"
                        podiumColorHex = "#C09DDF"
                    default:
                        image = "PlayerYellow"
                        podiumColorHex = "#F3CC02"
                    }

                    return PlayerResult(
                        userId: entry.id,
                        displayName: entry.id == self.userId ? "You" : entry.displayName,
                        score: entry.score,
                        imageName: image,
                        podiumColorHex: podiumColorHex
                    )
                }

                self.finalResults = mapped
                self.showResults = true
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
            self.answeredPlayers = []
            print("✅ [GameVM] Question updated in ViewModel at index: \(index)")
        }
    }

    func leaveGame() {
        print("[GameVM] Leaving game...")
        socket.emit("leaveMultiplayerGame", ["userId": userId])
        socket.removeAllHandlers()
        
        // Reset all local game state
        DispatchQueue.main.async {
            self.currentQuestion = nil
            self.currentIndex = 0
            self.totalQuestions = 0
            self.isGameOver = false
            self.playerScores = [:]
            self.correctAnswer = nil
            self.hasAnsweredCurrentQuestion = false
            self.selectedAnswer = nil
            self.finalResults = []
            self.showResults = false
        }
    }

}
