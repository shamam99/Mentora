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
                    Button(action: {
                        SoundPlayer.shared.playSound(named: "3")
                        vm.resetGame() 
                        SoloGameService.shared.resetGame()
                        SocketService.shared.disconnect()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            NavigationUtil.popToRootView()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.custom("IBMPlexMono-Bold", size: 45))
                            .foregroundColor(.black)
                            .padding(.leading, 82)
                            .padding(.top, 42)
                    }
                    Spacer()
                }
                Spacer()
            }

            if vm.showResult {
                ZStack {
                    // Top decoration corners
                    HStack(spacing: -30) {
                        Image("topCorner")
                            .resizable()
                            .frame(width: 480, height: 340)
                            .offset(x: 245, y: 105)

                        Image("topCorner")
                            .resizable()
                            .frame(width: 180, height: 140)
                            .rotationEffect(.degrees(180))
                            .offset(x: 5)
                    }
                    .offset(y: -190)

                    // Bottom decoration corners
                    HStack(spacing: -30) {
                        Image("bottomCorner")
                            .resizable()
                            .frame(width: 480, height: 340)
                            .offset(x: -85, y: -105)

                        Image("bottomCorner")
                            .resizable()
                            .frame(width: 180, height: 140)
                            .rotationEffect(.degrees(180))
                            .offset(x: -450, y: -40)
                    }
                    .offset(y: 190)

                    // Center yellow card with result
                    ZStack {
                        Image("middleCard")
                            .resizable()
                            .frame(width: 640, height: 370)

                        VStack(spacing: 32) {
                            Text("Game Over")
                                .font(.custom("IBMPlexMono-Bold", size: 32))
                                .foregroundColor(.black)

                            Text(vm.supportiveMessage)
                                .font(.custom("IBMPlexMono-Regular", size: 20))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)

                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black)
                                    .frame(width: 230, height: 52)
                                    .offset(y: 1.5)

                                Button(action: {
                                    SoundPlayer.shared.playSound(named: "3")
                                    NavigationUtil.popToRootView()
                                }) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "#05D96A"))
                                        .frame(width: 225, height: 46)
                                        .overlay(
                                            Text("Score: \(vm.finalScore ?? 0)/\(vm.total)")
                                                .font(.custom("IBMPlexMono-Bold", size: 18))
                                                .foregroundColor(.black)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .transition(.opacity)
            }else {
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

                        Image("btnLeft")
                            .resizable()
                            .frame(width: 32, height: 42)
                            .onTapGesture { swipe(.left) }

                        ZStack {
                            Image("counterBadge")
                                .resizable()
                                .frame(width: 70, height: 80)
                                .padding(.top, 15)

                            Text("\(vm.currentIndex)")
                                .font(.custom("IBMPlexMono-Bold", size: 20))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 20)

                        Image("btnRight")
                            .resizable()
                            .frame(width: 32, height: 42)
                            .onTapGesture { swipe(.right) }

                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            cardStack = []
            vm.resetGame()
            vm.startGame()
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
                    return Image("CardPink2")
                }
            }()

            cardImage
                .resizable()
                .frame(width: cardSize.width, height: cardSize.height)
                .shadow(radius: 4)

            Text(question.text)
                .font(.custom("IBMPlexMono-Bold", size: 20))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .frame(width: 250, height: 140)
                .offset(y: 100)
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
    ZStack {
        Color(hex: "#FEFAED").ignoresSafeArea()
        Image("bg").resizable().scaledToFill().ignoresSafeArea()

        ZStack {
            // Top decoration corners
            HStack(spacing: -30) {
                Image("topCorner")
                    .resizable()
                    .frame(width: 480, height: 340)
                    .offset(x: 245, y: 105)
                Image("topCorner")
                    .resizable()
                    .frame(width: 180, height: 140)
                    .rotationEffect(.degrees(180))
                    .offset(x: 5)
            }
            .offset(y: -190)
            
            // Bottom decoration corners
            HStack(spacing: -30) {
                Image("bottomCorner")
                    .resizable()
                    .frame(width: 480, height: 340)
                    .offset(x: -85, y: -105)
                Image("bottomCorner")
                    .resizable()
                    .frame(width: 180, height: 140)
                    .rotationEffect(.degrees(180))
                    .offset(x: -450, y:-40)
            }
            .offset(y: 190)

            // Middle yellow card
            ZStack {
                Image("middleCard")
                    .resizable()
                    .frame(width: 640, height: 370)

                VStack(spacing: 32) {
                    Text("Game Over")
                        .font(.custom("IBMPlexMono-Bold", size: 32))
                        .foregroundColor(.black)

                    Text("Great job! You're almost perfect. 🎯")
                        .font(.custom("IBMPlexMono-Regular", size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)

                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black)
                            .frame(width: 230, height: 52)
                            .offset(y: 1.5)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "#05D96A"))
                            .frame(width: 225, height: 46)
                            .overlay(
                                Text("Score: 7/10")
                                    .font(.custom("IBMPlexMono-Bold", size: 18))
                                    .foregroundColor(.black)
                            )
                    }
                }
            }

        }
    }
    .previewDevice("iPad Pro (13-inch)")
    .previewInterfaceOrientation(.landscapeLeft)
}

