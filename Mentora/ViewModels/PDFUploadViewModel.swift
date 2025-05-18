//
//  PDFUploadViewModel.swift
//  Mentora
//
//  Created by Shamam Alkafri on 13/05/2025.
//

import Foundation

class PDFUploadViewModel: ObservableObject {
    let userId: String
    let displayName: String
    let mode: String
    var roomVM: RoomViewModel?

    @Published var questions: [Question] = []
    @Published var isLoading = false
    @Published var extractedText: String = ""
    @Published var navigateToGame = false
    @Published var navigateToMultiplayerLobby = false

    init(userId: String, displayName: String, mode: String, roomVM: RoomViewModel?) {
        self.userId = userId
        self.displayName = displayName
        self.mode = mode
        self.roomVM = roomVM
    }

    func sendToBackend() {
        isLoading = true
        APIService.shared.generateQuestions(from: extractedText, mode: mode) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let questions):
                    self.questions = questions

                    let formatted: [[String: Any]] = self.questions.enumerated().map { (index, q) in
                        if self.mode == "mcq" {
                            let validChoices = q.choices?.map { $0.answer } ?? []
                            return [
                                "question": q.question ?? "Untitled #\(index)",
                                "correct_answer": q.correct_answer ?? "",
                                "choices": q.choices?.map { ["answer": $0.answer, "correct": $0.correct] } ?? []
                            ]
                        } else {
                            return [
                                "question": q.statement ?? q.question ?? "Untitled #\(index)",
                                "is_true": q.is_true ?? false
                            ]
                        }
                    }
                    
                    let backendMode = (self.mode == "mcq") ? "multiplayer" : "solo"

                    APIManager.shared.submitQuestionsToBackend(mode: backendMode, userId: self.userId, questions: formatted) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                if self.mode == "mcq" {
                                    self.navigateToMultiplayerLobby = true
                                } else {
                                    self.navigateToGame = true
                                }
                            case .failure(let error):
                                print("Submit error:", error.localizedDescription)
                            }
                        }
                    }


                case .failure(let error):
                    self.extractedText = " Error: \(error.localizedDescription)"
                }
            }
        }
    }

    // inside class scope
    private func emitJoinRoomForHost() {
        let socket = SocketService.shared.getSocket()
        let payload: [String: String] = [
            "userId": userId,
            "displayName": displayName,
            "pinCode": roomVM?.pinCode ?? ""
        ]

        print("[PDFUploadViewModel] Preparing to emit joinMultiplayerRoom (Host): \(payload)")

        if socket.status != .connected {
            socket.once("connect") { _, _ in
                print("[PDFUploadViewModel] Socket connected. Emitting now.")
                socket.emit("joinMultiplayerRoom", payload)
            }
            print("[PDFUploadViewModel] Connecting socket...")
            socket.connect()
        } else {
            print("[PDFUploadViewModel] Already connected. Emitting joinMultiplayerRoom.")
            socket.emit("joinMultiplayerRoom", payload)
        }
    }
}
