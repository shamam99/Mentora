//
//  MultiplayerGameView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 07/05/2025.
//

import SwiftUI

struct MultiplayerGameView: View {
    @StateObject var vm: MultiplayerGameViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            if vm.isGameOver {
                VStack(spacing: 24) {
                    Text("Game Over")
                        .font(.largeTitle)
                        .bold()

                    ForEach(vm.playerScores.sorted(by: { $0.value > $1.value }), id: \.key) { player, score in
                        Text("\(player): \(score) pts")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }

                    Button("Back to Home") {
                        vm.leaveGame()
                        dismiss()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding()
            }
            else if let question = vm.currentQuestion {
                VStack(spacing: 16) {
                    Text("Question \(vm.currentIndex) of \(vm.totalQuestions)")
                        .font(.headline)

                    Text(question.text)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()

                    ForEach(question.choices, id: \.self) { choice in
                        Button(action: {
                            vm.submitAnswer(choice)
                        }) {
                            Text(choice)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            else {
                VStack(spacing: 16) {
                    ProgressView("Waiting for Game Start...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Stay ready! Game will begin shortly.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
            }
        }
        .padding()
        .onDisappear {
            vm.leaveGame()
        }
    }
}

/// Wrapper to safely unwrap optional gameVM before navigating
struct MultiplayerGameViewWrapper: View {
    let gameVM: MultiplayerGameViewModel?

    var body: some View {
        if let vm = gameVM {
            MultiplayerGameView(vm: vm)
        } else {
            VStack {
                Text("Error: Game could not start")
                    .foregroundColor(.red)
                Button("Back") {
                    // Optional: add logic to dismiss or pop view
                }
            }
        }
    }
}
