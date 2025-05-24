//
//  SoloGameViewModel.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//

import Foundation
import Combine

class SoloGameViewModel: ObservableObject {
    @Published var userId: String
    @Published var question: SoloGameQuestion?
    @Published var currentIndex: Int = 0
    @Published var total: Int = 0
    @Published var showResult = false
    @Published var finalScore: Int?

    private var service = SoloGameService.shared
    private var cancellables = Set<AnyCancellable>()

    init(userId: String) {
        self.userId = userId

        // Bind service updates to view model
        service.$currentQuestion
            .receive(on: RunLoop.main)
            .assign(to: &$question)

        service.$currentIndex
            .receive(on: RunLoop.main)
            .assign(to: &$currentIndex)

        service.$totalQuestions
            .receive(on: RunLoop.main)
            .assign(to: &$total)

        service.$finalScore
            .receive(on: RunLoop.main)
            .sink { [weak self] score in
                if let score = score {
                    self?.finalScore = score
                    self?.showResult = true
                }
            }
            .store(in: &cancellables)
    }

    func startGame() {
        service.startGame(userId: userId)
    }

    func submitAnswer(_ answer: String) {
        service.sendAnswer(answer)
    }

    func resetGame() {
        service.resetGame()
        showResult = false
        finalScore = nil
        question = nil
        currentIndex = 0
        total = 0
    }
    
    var supportiveMessage: String {
        guard let score = finalScore else { return "" }
        let percentage = Double(score) / Double(total)

        switch percentage {
        case 0..<0.4:
            return "It's okay to miss a few! You're on your way."
        case 0.4..<0.7:
            return "Not bad! You're learning fast. Try again?"
        case 0.7..<0.9:
            return "Great job! You're almost perfect."
        default:
            return "Outstanding! You nailed it! 🎉"
        }
    }
}
