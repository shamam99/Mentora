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
    @State private var isInMultiplayerGame = false

    @State private var selectedAnswer: String? = nil
    @State private var answerResult: String? = nil

    var body: some View {
        ZStack {
            Color(hex: "#FEFAED").ignoresSafeArea()
            Image("bg").resizable().scaledToFill().ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                Spacer()

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
        NavigationLink(
            destination: MultiplayerResultsView(players: vm.finalResults, vm: vm, isInMultiplayerGame: $isInMultiplayerGame),
            isActive: $vm.showResults
        ) {
            EmptyView()
        }
    }

    // MARK: - Question View
    func gameQuestionView(_ question: MultiplayerQuestion) -> some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let cardWidth = screenWidth * 0.65
            let cardHeight: CGFloat = cardWidth * 0.32
            let buttonWidth = screenWidth * 0.30

            VStack(spacing: 48) {
                // Question Card
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black)
                        .frame(width: cardWidth + 15, height: cardHeight + 20)

                    Image("quizcard")
                        .resizable()
                        .frame(width: cardWidth, height: cardHeight)

                    Text(question.question)
                        .font(.custom("IBMPlexMono-Bold", size: screenWidth > 1024 ? 22 : 20))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                        .frame(width: cardWidth * 0.63, height: cardHeight * 0.6)
                }
                .frame(height: cardHeight + 20)

                // Answer Buttons Grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: -360),
                        GridItem(.flexible(), spacing: -230)
                    ],
                    spacing: 24
                ) {
                    ForEach(question.choices.indices, id: \.self) { index in
                        let choice = question.choices[index]

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black)
                                .frame(width: buttonWidth + 5, height: 80)
                                .offset(y: 3.5)

                            Button(action: {
                                selectedAnswer = choice
                                vm.selectedAnswer = choice
                                vm.submitAnswer(choice)
                            }) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(buttonColor(for: choice))
                                    .frame(width: buttonWidth, height: 70)
                                    .overlay(
                                        Text(choice)
                                            .font(.custom("IBMPlexMono-Bold", size: 18))
                                            .foregroundColor(.black)
                                    )
                            }
                            .buttonStyle(NoEffectButtonStyle())
                            .disabled(vm.hasAnsweredCurrentQuestion)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 40)
            .padding(.top, 20)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }


    // MARK: - Exit + Avatars + Progress
    private var topBar: some View {
        VStack(spacing: 0) {
            BackExitButton(icon: "xmark", topPadding: 24, leftPadding: 24, sound: "3") {
                vm.leaveGame()
                SocketService.shared.disconnect()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    NavigationUtil.popToRootView()
                }
            }
            HStack {
                Spacer()
                
                VStack{
                    HStack{
                        ForEach(vm.playersInRoom, id: \.self) { playerId in
                            Image("profileImage 1")
                                .resizable()
                                .frame(width: 42, height: 44)
                                .opacity(vm.answeredPlayers.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines) == playerId.trimmingCharacters(in: .whitespacesAndNewlines) }) ? 1.0 : 0.4)
                                .overlay(Circle().stroke(Color.black, lineWidth: 1))
                                
                        }
                    }
                    Text("\(vm.currentIndex) / \(vm.totalQuestions)")
                        .font(.custom("IBMPlexMono-Bold", size: 22))
                        .foregroundColor(.black)
                        .padding(.leading, 12)
                        .padding(.trailing, 20)
                }
                .padding(.trailing, 42)
                .offset(y: -18)
            }
            
        }
    }

    private func buttonColor(for choice: String) -> Color {
        guard let selected = selectedAnswer,
              let correct = vm.correctAnswer else {
            return Color(hex: "#0DA8E2") // default blue
        }

        if choice == selected {
            return selected == correct ? Color(hex: "#05D96A") : Color(hex: "#DA4820")
        }

        return Color(hex: "#0DA8E2")
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
                SocketService.shared.disconnect()
                NavigationUtil.popToRootView()
            }
            .padding()
            .frame(width: 240)
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

struct NoEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
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

        dummy.playersInRoom = ["dummy", "player2", "player3"]

        dummy.answeredPlayers = ["player2"]

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

