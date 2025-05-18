//
//  MultiplayerGameView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 07/05/2025.
//


import SwiftUI

struct MultiplayerGameView: View {
    @ObservedObject var vm: MultiplayerGameViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedAnswer: String? = nil
    @State private var answerResult: String? = nil
    
    var body: some View {
        ZStack {
            Color(hex: "#FEFAED").ignoresSafeArea()
            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                Spacer()
                VStack(alignment: .leading, spacing: 30) {
                    Button(action: {
                        vm.leaveGame()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                    }
                    Text("\(vm.currentIndex) / \(vm.totalQuestions)")
                        .font(.custom("IBMPlexMono-Bold", size: 22))
                        .foregroundColor(.black)
                }
                .padding(.leading, 32)
                .padding(.top, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                
                
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
                        gameQuestionView(vm.currentQuestion!)
                            .transition(.opacity)
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("🎮 MultiplayerGameView appeared")
        }
        .onReceive(vm.$currentQuestion) { q in
            print("📲 UI received question update: \(q?.question ?? "nil")")
        }
    }
    
    func gameQuestionView(_ question: MultiplayerQuestion) -> some View {
        print(" UI drawing question card with text: \(question.question)")
        
        return VStack(spacing: 66) {
            
            // Stylized Question Card
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black)
                    .frame(width: 760, height: 285)
                
                ZStack {
                    GeometryReader { geometry in
                        Image("quizcard")
                            .resizable()
                            .frame(width: geometry.size.width)
                            .aspectRatio(2, contentMode: .fit)
                        
                        VStack {
                            Spacer()
                            Text(question.question)
                                .font(.custom("IBMPlexMono-Bold", size: 22))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 32)
                            Spacer()
                        }
                        .frame(width: geometry.size.width - 30)
                    }
                    .frame(width: 750, height: 255)
                }
                .offset(y: -10)
            }
            
            // Stylized Answer Buttons as Grid
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 50),
                    GridItem(.flexible(), spacing: 30)
                ],
                spacing: 30
            ) {
                ForEach(question.choices.indices, id: \.self) { index in
                    let choice = question.choices[index]

                    ZStack {
                        // Always show black shadow
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                            .frame(height: 70)

                        Button(action: {
                            selectedAnswer = choice
                            vm.selectedAnswer = choice
                            vm.submitAnswer(choice)
                        }) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(buttonColor(for: choice))
                                .frame(height: 60)
                                .overlay(
                                    Text(choice)
                                        .font(.custom("IBMPlexMono-Bold", size: 26))
                                        .foregroundColor(.black)
                                )
                        }
                        .offset(y: selectedAnswer == choice ? -8 : -4)
                        .buttonStyle(.plain)
                        .disabled(vm.hasAnsweredCurrentQuestion)
                    }
                }

            }
            .frame(width: 760)
            
        }
    }
    
    
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
    
    private func buttonColor(for choice: String) -> Color {
        if let selected = selectedAnswer, let result = answerResult {
            if choice == selected && result == "correct" {
                return Color(hex: "#05D96A") // Green
            } else if choice == selected && result == "incorrect" {
                return Color(hex: "#DA4820") // Red
            } else if choice == vm.currentQuestion?.correct {
                return Color(hex: "#05D96A") // Show correct answer after selection
            } else {
                return Color(hex: "#A6D6EC") // Faded blue for unselected
            }
        } else {
            return Color(hex: "#0DA8E2") // Default blue
        }
    }
}




// MARK: - Wrapper View
struct MultiplayerGameViewWrapper: View {
    @ObservedObject var vm: MultiplayerGameViewModel

    var body: some View {
        MultiplayerGameView(vm: vm)
    }
}


extension MultiplayerGameViewModel {
    static func previewDummy() -> MultiplayerGameViewModel {
        let dummy = MultiplayerGameViewModel(userId: "dummy")
        dummy.currentQuestion = MultiplayerQuestion(
            question: "True or False? IPv4 addresses are 32 bits. or more than that around the 64 ",
            choices: ["True", "False", "Answer 3", "Answer 4"],
            correct: "True"
        )
        dummy.currentIndex = 3
        dummy.totalQuestions = 12
        return dummy
    }
}


// MARK: - Preview
#Preview {
    MultiplayerGameViewWrapper(
        vm: MultiplayerGameViewModel.previewDummy()
    )
    .previewDevice("iPad Pro (11-inch)")
    .previewInterfaceOrientation(.landscapeLeft)
}

