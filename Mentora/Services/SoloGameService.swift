//
//  SoloGameService.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//


import Foundation
import SocketIO

class SoloGameService: ObservableObject {
    static let shared = SoloGameService()

    private var socket: SocketIOClient

    @Published var currentQuestion: SoloGameQuestion?
    @Published var isGameOver: Bool = false
    @Published var currentIndex: Int = 0
    @Published var totalQuestions: Int = 0
    @Published var lastAnswerCorrect: Bool?
    @Published var correctAnswer: String?
    @Published var finalScore: Int?

    private init() {
        self.socket = SocketService.shared.getSocket()
        setupListeners()
    }

    func startGame(userId: String) {
        resetGame()
        if socket.status == .connected {
            socket.emit("soloStartGame", ["userId": userId])
        } else {
            socket.once("connect") { [weak self] _, _ in
                self?.socket.emit("soloStartGame", ["userId": userId])
            }
            socket.connect()
        }
    }

    func sendAnswer(_ answer: String) {
        socket.emit("soloAnswer", answer)
    }

    private func setupListeners() {
        socket.on("soloQuestion") { [weak self] data, _ in
            guard let self = self else { return }

            if let dict = data.first as? [String: Any],
               let questionDict = dict["question"] as? [String: Any],
               let text = questionDict["text"] as? String,
               let choices = questionDict["choices"] as? [String],
               let index = dict["index"] as? Int,
               let total = dict["total"] as? Int {
                DispatchQueue.main.async {
                    self.currentQuestion = SoloGameQuestion(text: text, choices: choices)
                    self.currentIndex = index
                    self.totalQuestions = total
                    self.lastAnswerCorrect = nil
                    self.correctAnswer = nil
                }
            }
        }

        socket.on("soloAnswerResult") { [weak self] data, _ in
            guard let self = self else { return }

            if let dict = data.first as? [String: Any],
               let correct = dict["correct"] as? Bool,
               let correctAns = dict["correctAnswer"] as? String {
                DispatchQueue.main.async {
                    self.lastAnswerCorrect = correct
                    self.correctAnswer = correctAns
                }
            }
        }

        socket.on("soloGameOver") { [weak self] data, _ in
            guard let self = self else { return }

            if let dict = data.first as? [String: Any],
               let score = dict["score"] as? Int {
                DispatchQueue.main.async {
                    self.finalScore = score
                    self.isGameOver = true
                }
            }
        }
    }

    private func resetGame() {
        currentQuestion = nil
        currentIndex = 0
        totalQuestions = 0
        lastAnswerCorrect = nil
        correctAnswer = nil
        finalScore = nil
    }
}
