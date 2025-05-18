//
//  SoloGameSwipeView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 15/05/2025.
//

import SwiftUI

struct SoloGameSwipeView: View {
    @StateObject var vm: SoloGameViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @GestureState private var dragOffset: CGSize = .zero
    @State private var cardOffset: CGSize = .zero
    @State private var swipeDirection: SwipeDirection? = nil
    @State private var fadeOut = false

    @State private var cardStack: [SoloGameQuestion] = []

    enum SwipeDirection {
        case left, right
    }

    var body: some View {
        ZStack {
            Color(hex: "#FEFAED").ignoresSafeArea()
            Image("bg").resizable().scaledToFill().ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Text("X")
                            .font(.custom("IBMPlexMono-Bold", size: 50))
                            .foregroundColor(.black)
                            .padding(.leading, 42)
                            .padding(.top, 42)
                    }
                    Spacer()
                }
                Spacer()
            }

            if vm.showResult {
                VStack(spacing: 24) {
                    Text("Game Over")
                        .font(.largeTitle).bold()
                    Text("Your Score: \(vm.finalScore ?? 0)/\(vm.total)")
                        .font(.title2).foregroundColor(.green)
                }
            } else {
                VStack {
                    Spacer()

                    ZStack {
                        if cardStack.count > 1 {
                            cardView(cardStack[1], showTop: false)
                                .offset(x: 0, y: 10)
                        }

                        if let current = cardStack.first {
                            cardView(current, showTop: true)
                                .offset(x: cardOffset.width * 0.3)
                                .opacity(fadeOut ? 0 : 1)
                                .gesture(
                                    DragGesture()
                                        .updating($dragOffset) { value, state, _ in
                                            state = value.translation
                                        }
                                        .onEnded { value in
                                            if value.translation.width > 100 {
                                                swipe(.right)
                                            } else if value.translation.width < -100 {
                                                swipe(.left)
                                            } else {
                                                cardOffset = .zero
                                            }
                                        }
                                )
                                .animation(.easeInOut(duration: 0.2), value: cardOffset)
                        }
                    }

                    Spacer()

                    HStack(spacing: 36) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                            .onTapGesture { swipe(.left) }

                        Image("btnLeft")
                            .resizable()
                            .frame(width: 32, height: 42)
                            .onTapGesture { swipe(.left) }

                        ZStack {
                            Image("counterBadge")
                                .resizable()
                                .frame(width: 70, height: 80)

                            Text("\(vm.currentIndex)")
                                .font(.custom("IBMPlexMono-Bold", size: 20))
                                .foregroundColor(.black)
                        }

                        Image("btnRight")
                            .resizable()
                            .frame(width: 32, height: 42)
                            .onTapGesture { swipe(.right) }

                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                            .onTapGesture { swipe(.right) }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            vm.resetGame()
            vm.startGame()
            cardStack = []
        }
        .onChange(of: vm.question) { newQuestion in
            if let q = newQuestion {
                cardStack.append(q)
            }
        }
    }

    @ViewBuilder
    func cardView(_ question: SoloGameQuestion, showTop: Bool) -> some View {
        ZStack {
            let cardSize = CGSize(width: 480, height: 650)

            let cardImage = {
                if swipeDirection == .left && showTop {
                    return Image("CardRed")
                } else if swipeDirection == .right && showTop {
                    return Image("CardGreen")
                } else {
                    return Image("CardPink")
                }
            }()

            cardImage
                .resizable()
                .frame(width: cardSize.width, height: cardSize.height)
                .shadow(radius: 4)

            Text(question.text)
                .font(.custom("IBMPlexMono-Bold", size: 16))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .frame(width: 250, height: 120)
                .offset(y: 140)
        }
        .frame(width: 520, height: 650)

    }

    private func swipe(_ direction: SwipeDirection) {
        swipeDirection = direction
        triggerHaptic()

        withAnimation(.easeInOut(duration: 0.25)) {
            cardOffset = CGSize(width: direction == .right ? 200 : -200, height: 0)
            fadeOut = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            cardOffset = .zero
            fadeOut = false
            swipeDirection = nil
            if !cardStack.isEmpty { cardStack.removeFirst() }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let answer = direction == .right ? "True" : "False"
                vm.submitAnswer(answer)
            }
        }
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}



#Preview {
    PDFUploadView(vm: PDFUploadViewModel(
        userId: "test",
        displayName: "Test",
        mode: "tf",
        roomVM: RoomViewModel()
    ))
    .environmentObject(AuthViewModel())
    .previewDevice("iPad Pro (11-inch)")
    .previewInterfaceOrientation(.landscapeLeft)
}
