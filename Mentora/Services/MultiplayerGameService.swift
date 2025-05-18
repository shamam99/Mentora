////
////  MultiplayerGameService.swift
////  Mentora
////
////  Created by Shamam Alkafri on 08/05/2025.
////
//
//import Foundation
//import SocketIO
//
//final class MultiplayerGameService {
//    static let shared = MultiplayerGameService()
//
//    private var socket: SocketIOClient!
//    private var userId: String = ""
//    private var onQuestionReceived: ((MultiplayerQuestion, Int, Int) -> Void)?
//    private var onAnswerResult: ((String, Int) -> Void)?
//    private var onGameOver: (([String: Int]) -> Void)?
//
//    private init() {
//        self.socket = SocketService.shared.getSocket()
//    }
//
//    func configure(userId: String) {
//        self.userId = userId
//    }
//
//    func onQuestion(_ callback: @escaping (MultiplayerQuestion, Int, Int) -> Void) {
//        self.onQuestionReceived = callback
//    }
//
//    func onAnswer(_ callback: @escaping (String, Int) -> Void) {
//        self.onAnswerResult = callback
//    }
//
//    func onGameOver(_ callback: @escaping ([String: Int]) -> Void) {
//        self.onGameOver = callback
//    }
//
//    func listenForGameEvents() {
//        socket.off("multiplayerQuestion")
//        socket.off("multiplayerAnswerResult")
//        socket.off("multiplayerGameOver")
//
//        socket.on("multiplayerQuestion") { [weak self] data, _ in
//            guard let self = self,
//                  let payload = data.first as? [String: Any],
//                  let index = payload["index"] as? Int,
//                  let total = payload["total"] as? Int,
//                  let questionDict = payload["question"] as? [String: Any],
//                  let choices = questionDict["choices"] as? [String] else {
//                print(" Invalid multiplayerQuestion payload")
//                return
//            }
//
//            let questionText =
//                questionDict["text"] as? String ??
//                questionDict["questionText"] as? String ??
//                questionDict["question"] as? String ??
//                ""
//
//            let correctAnswer = questionDict["correct"] as? String ?? ""
//
//            print("Question received: \(questionText)")
//
//            let question = MultiplayerQuestion(question: questionText, choices: choices, correct: correctAnswer)
//            self.onQuestionReceived?(question, index, total)
//
//        }
//
//        socket.on("multiplayerAnswerResult") { [weak self] data, _ in
//            guard let self = self,
//                  let payload = data.first as? [String: Any],
//                  let playerId = payload["player"] as? String,
//                  let score = payload["score"] as? Int else {
//                return
//            }
//
//            print("[GameService] \(playerId) score updated to \(score)")
//            self.onAnswerResult?(playerId, score)
//        }
//
//        socket.on("multiplayerGameOver") { [weak self] data, _ in
//            guard let self = self,
//                  let scoreDict = data.first as? [String: Int] else {
//                return
//            }
//
//            self.onGameOver?(scoreDict)
//        }
//    }
//
//    func submitAnswer(_ answer: String) {
//        guard !userId.isEmpty else { return }
//
//        let payload: [String: String] = [
//            "userId": userId,
//            "answer": answer
//        ]
//
//        print("[GameService] Submitting answer: \(answer) from user: \(userId)")
//        socket.emit("submitMultiplayerAnswer", payload)
//    }
//}
