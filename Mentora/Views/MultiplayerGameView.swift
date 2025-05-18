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
    @State private var selectedAnswer: String? = nil
    @State private var answerResult: String? = nil

    var safeQuestion: MultiplayerQuestion {
        vm.currentQuestion ?? MultiplayerQuestion(question: "", choices: [], correct: "")
    }

    var body: some View {
        ZStack {
            Color(hex: "#FEFAED").ignoresSafeArea()
            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Top Bar
                HStack {
                    Button(action: {
                        vm.leaveGame()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    Text("\(vm.currentIndex) / \(vm.totalQuestions)")
                        .font(.custom("IBMPlexMono-Bold", size: 20))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 32)
                .padding(.top, 12)

                Spacer()

                Group {
                    if vm.isGameOver {
                        gameOverView
                    } else if vm.currentQuestion == nil {
                        ProgressView("Loading first question...")
                            .font(.custom("IBMPlexMono-Regular", size: 18))
                            .foregroundColor(.gray)
                            .padding(.top, 120)
                    } else {
                        gameQuestionView(safeQuestion)
                            .transition(.opacity)
                            .id(UUID()) // force redraw
                    }
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("🎮 MultiplayerGameView appeared")
            vm.onAnswerFeedback = { selected, correct in
                withAnimation(.easeInOut(duration: 0.3)) {
                    answerResult = selected == correct ? "correct" : "incorrect"
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    selectedAnswer = nil
                    answerResult = nil
                }
            }
        }
        .onDisappear {
            vm.leaveGame()
        }
    }


    // MARK: - Game View (Live Question)
    func gameQuestionView(_ question: MultiplayerQuestion) -> some View {
        print("📲 UI drawing question card with text: \(question.question)")

        return VStack(spacing: 36) {
            ZStack {
                Image("quizcard")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 600, height: 220)

                Text(question.question)
                    .font(.custom("IBMPlexMono-Bold", size: 22))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 20) {
                ForEach(question.choices.indices, id: \.self) { index in
                    let choice = question.choices[index]
                    Button(action: {
                        selectedAnswer = choice
                        vm.selectedAnswer = choice
                        vm.submitAnswer(choice)
                    }) {
                        Text(choice)
                            .font(.custom("IBMPlexMono-Bold", size: 20))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(buttonColor(for: choice))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.25), radius: 4, x: 2, y: 2)
                    }
                    .padding(.horizontal, 120)
                    .disabled(vm.hasAnsweredCurrentQuestion)
                }
            }
        }
    }

    // MARK: - Game Over View
    var gameOverView: some View {
        VStack(spacing: 20) {
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
            .frame(width: 240)
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }

    // MARK: - Color Handling
    private func buttonColor(for choice: String) -> Color {
        guard let selected = selectedAnswer, let result = answerResult else {
            return Color(hex: "#0DA8E2")
        }

        if choice == selected && result == "incorrect" {
            return Color(hex: "#DA4820")
        } else if choice == selected && result == "correct" {
            return Color(hex: "#05D96A")
        } else {
            return Color(hex: "#0DA8E2")
        }
    }
}

// MARK: - Wrapper View
struct MultiplayerGameViewWrapper: View {
    let gameVM: MultiplayerGameViewModel?

    var body: some View {
        if let vm = gameVM {
            MultiplayerGameView(vm: vm)
                .onAppear {
                    print("📦 Entered MultiplayerGameViewWrapper with gameVM: \(String(describing: gameVM))")
                    vm.setupListeners()
                }
        } else {
            VStack(spacing: 20) {
                Text("Error: Game could not start")
                    .foregroundColor(.red)

                Button("Back") {
                    // Handle navigation
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MultiplayerGameView(
        vm: MultiplayerGameViewModel(userId: "test-id")
    )
    .previewDevice("iPad Pro (11-inch)")
    .previewInterfaceOrientation(.landscapeLeft)
}
