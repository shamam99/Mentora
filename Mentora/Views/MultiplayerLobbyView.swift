
//  MultiplayerLobbyView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//


import SwiftUI

struct MultiplayerLobbyView: View {
    @StateObject private var vm = MultiplayerLobbyViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoadingGame = true

    let userId: String
    let displayName: String
    let pinCode: String?

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(hex: "#FEFAED").ignoresSafeArea()
            Image("bg").resizable().scaledToFill().ignoresSafeArea()

            VStack {
                // Back
                HStack {
                    BackExitButton(icon: "chevron.left", topPadding: 50, leftPadding: 42, sound: "3") {
                        vm.leaveLobby()
                        presentationMode.wrappedValue.dismiss()
                    }
                    Spacer()
                }

                // Puzzle Grid
                PuzzleGridView(players: vm.players)

                Spacer()

                // Bottom bar
                GeometryReader { geometry in
                    let screenWidth = geometry.size.width
                    let horizontalPadding = screenWidth * 0.06

                    HStack {
                        Text("Code : \(vm.pinCode)")
                            .font(.custom("IBMPlexMono-Bold", size: 24))
                            .foregroundColor(.black)
                            .padding(.leading, horizontalPadding)

                        Spacer()

                        if vm.isHost {
                            Button(action: {
                                SoundPlayer.shared.playSound(named: "1")
                                vm.startGame()
                            }) {
                                Text("Start Game")
                                    .font(.custom("IBMPlexMono-Bold", size: 20))
                                    .foregroundColor(.black)
                                    .frame(width: 170, height: 58)
                                    .background(vm.canStartGame ? Color(hex: "#05D96A") : Color.gray)
                                    .cornerRadius(8)
                                    .shadow(color: .black.opacity(0.5), radius: 0, x: 0, y: 6)
                            }
                            .padding(.trailing, horizontalPadding)
                            .disabled(!vm.canStartGame)
                        }
                    }
                    .frame(width: screenWidth)
                    .padding(.bottom, 52)
                }
                .frame(height: 80)
            }

            // Navigation
            NavigationLink(
                destination: Group {
                    if let gameVM = vm.gameVM, !isLoadingGame {
                        MultiplayerGameViewWrapper(vm: gameVM)
                    } else {
                        ProgressView("Starting game...")
                            .font(.custom("IBMPlexMono-Regular", size: 18))
                            .foregroundColor(.gray)
                    }
                },
                isActive: $vm.navigateToGame
            ) {
                EmptyView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            vm.initialize(userId: userId, displayName: displayName, pinCode: pinCode)
            vm.loadingCompleteCallback = {
                isLoadingGame = false
            }
        }
        .onDisappear {
            if !vm.navigateToGame {
                vm.leaveLobby()
            }
        }
    }
}

struct PuzzleGridView: View {
    let players: [String]
    private let playerImages = ["slot1", "slot2", "slot3", "slot4"]

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let pieceSize: CGFloat = min(screenHeight * 0.53, 350)

            VStack(spacing: -pieceSize * 0.25) {
                HStack(spacing: -pieceSize * 0.06) {
                    playerSlot(index: 0, pieceSize: pieceSize)
                    playerSlot(index: 1, pieceSize: pieceSize)
                }

                HStack(spacing: -pieceSize * 0.30) {
                    playerSlot(index: 2, pieceSize: pieceSize)
                    playerSlot(index: 3, pieceSize: pieceSize)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 700) // You can tweak this if needed
    }

    func playerSlot(index: Int, pieceSize: CGFloat) -> some View {
        let playerJoined = index < players.count
        let pieceImage = playerImages[index]

        return ZStack {
            Image(pieceImage)
                .resizable()
                .frame(width: pieceSize, height: pieceSize)
                .opacity(playerJoined ? 1.0 : 0.3)
        }
    }
}

#Preview {
    MultiplayerLobbyView(
        userId: "previewUser",
        displayName: "Shamam",
        pinCode: "1234"
    )
    .environmentObject(AuthViewModel())
    .previewDevice("iPad Pro (11-inch)")
    .previewInterfaceOrientation(.landscapeLeft)
}
