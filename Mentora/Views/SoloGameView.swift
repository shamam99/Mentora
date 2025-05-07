//
//  SoloGameView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//

import SwiftUI

struct SoloGameView: View {
    @StateObject var vm: SoloGameViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            //  PRIORITY: Show result if game over
            if vm.showResult {
                VStack(spacing: 24) {
                    Text(" Game Over")
                        .font(.largeTitle)
                        .bold()

                    Text("Your Score: \(vm.finalScore ?? 0)/\(vm.total)")
                        .font(.title2)
                        .foregroundColor(.green)

                    Button(action: {
                        dismiss()  
                    }) {
                        Text("Back to Home")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }
                .padding()

            //  If still in-game, show current question
            } else if let question = vm.question {
                Text("Question \(vm.currentIndex) of \(vm.total)")
                    .font(.headline)
                Text(question.text)
                    .font(.title3)
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

            //  Loading state
            } else {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .padding()
        .onAppear {
            vm.startGame()
        }
    }
}
