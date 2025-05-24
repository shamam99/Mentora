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
            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {

                    topBar
                
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
        
        NavigationLink(
            destination: MultiplayerResultsView(players: vm.finalResults, vm: vm, isInMultiplayerGame: $isInMultiplayerGame),
            isActive: $vm.showResults
        ) {
            EmptyView()
        }
        
    }
    
    func gameQuestionView(_ question: MultiplayerQuestion) -> some View {
        print(" UI drawing question card with text: \(question.question)")
        
        return VStack(spacing: 96) {
            
            // Stylized Question Card
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black)
                    .frame(width: 870, height: 300)
                
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
                    .frame(width: 850, height: 275)
                }
                .offset(y: -10)
            }
            
            // Stylized Answer Buttons as Grid
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 160),
                    GridItem(.flexible(), spacing: 160)
                ],
                spacing: 30
            ) {
                ForEach(question.choices.indices, id: \.self) { index in
                    let choice = question.choices[index]

                    ZStack {
                        // Bottom black base (always visible)
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                            .frame(width: 375, height: 80)

                        // Top answer button
                        Button(action: {
                            selectedAnswer = choice
                            vm.selectedAnswer = choice
                            vm.submitAnswer(choice)
                        }) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(buttonColor(for: choice))
                                .frame(width: 370, height: 70)
                                .overlay(
                                    Text(choice)
                                        .font(.custom("IBMPlexMono-Bold", size: 20))
                                        .foregroundColor(.black)
                                )
                        }
                        .padding(.bottom,7)
                        .buttonStyle(NoEffectButtonStyle())
                        .disabled(vm.hasAnsweredCurrentQuestion)
                    }

                }
            }
            .frame(width: 760)

            
        }
        .padding(.bottom, 100)
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
    
    private func buttonColor(for choice: String) -> Color {
        guard let selected = selectedAnswer,
              let correct = vm.correctAnswer else {
            return Color(hex: "#0DA8E2") // default blue
        }

        if choice == selected {
            return selected == correct
                ? Color(hex: "#05D96A") // green
                : Color(hex: "#DA4820") // red
        }

        return Color(hex: "#0DA8E2") // default blue
    }
    
    private var topBar: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                // Exit Button
                Button(action: {
                    SoundPlayer.shared.playSound(named: "3")
                    vm.leaveGame()
                    SocketService.shared.disconnect()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        NavigationUtil.popToRootView()
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.custom("IBMPlexMono-Bold", size: 45))
                        .foregroundColor(.black)
                        .padding(.top, 24)
                }

                Spacer()
            }
            .padding(.horizontal, 72)

            // Avatars
            HStack(spacing: 16) {
                Spacer()
                ForEach(vm.playersInRoom, id: \.self) { playerId in
                    Image("profileImage 1")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .opacity(vm.answeredPlayers.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines) == playerId.trimmingCharacters(in: .whitespacesAndNewlines) }) ? 1.0 : 0.4)
                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                }
            }
            .padding(.horizontal, 62)

            // Progress Text
            Text("\(vm.currentIndex) / \(vm.totalQuestions)")
                .font(.custom("IBMPlexMono-Bold", size: 28))
                .foregroundColor(.black)
                .padding(.horizontal, 72)
                .padding(.bottom, 24)
        }
    }

}

struct NoEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.0 : 1.0) // prevent scaling
            .brightness(configuration.isPressed ? 0 : 0)      // no visual shift
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

