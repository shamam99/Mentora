
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
            // Background
            Color(hex: "#FEFAED").ignoresSafeArea()
            Image("bg").resizable().scaledToFill().ignoresSafeArea()

            VStack {
                // Back Button
                HStack {
                    Button(action: {
                        vm.leaveLobby()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.black)
                            .padding(16)
                    }
                    Spacer()
                }

                Spacer()

                // Player Grid (Puzzle Layout)
                PuzzleGridView(players: vm.players)

                Spacer()

                // Bottom Row: Room Code + Start Button
                HStack {
                    // Room Code
                    Text("Code : \(vm.pinCode)")
                        .font(.custom("IBMPlexMono-Bold", size: 20))
                        .foregroundColor(.black)
                        .padding(.leading, 40)

                    Spacer()

                    // Host Start Button
                    if vm.isHost {
                        Button(action: {
                            vm.startGame()
                        }) {
                            Text("Start room")
                                .font(.custom("IBMPlexMono-Bold", size: 18))
                                .foregroundColor(.black)
                                .frame(width: 160, height: 48)
                                .background(vm.canStartGame ? Color(hex: "#05D96A") : Color.gray)
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.25), radius: 2, x: 2, y: 2)
                        }
                        .padding(.trailing, 40)
                        .disabled(!vm.canStartGame)
                    }
                }
                .padding(.bottom, 24)
            }

            // NavigationLink to MultiplayerGameView
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
            // Only leave lobby if game hasn't started
            if !vm.navigateToGame {
                vm.leaveLobby()
            }
        }


    }
}

// MARK: - Puzzle Grid Layout
struct PuzzleGridView: View {
    let players: [String]
    private let playerImages = ["Player1", "Player2", "Player3", "Player4"]

    var body: some View {
        VStack(spacing: -144) {
            HStack(spacing: -68) {
                playerSlot(index: 0)
                playerSlot(index: 1)
            }
            HStack(spacing: -76) {
                playerSlot(index: 2)
                playerSlot(index: 3)
            }
        }
    }

    func playerSlot(index: Int) -> some View {
        let playerJoined = index < players.count
        let imageName = playerImages[index]

        return ZStack {
            Image(imageName)
                .resizable()
                .frame(width: 370, height: 370)
                .opacity(playerJoined ? 1 : 0.3)
                .shadow(color: .black.opacity(playerJoined ? 0 : 0.25), radius: 4, x: 2, y: 2)

            if playerJoined {
                Text("Player \(index + 1)")
                    .font(.custom("IBMPlexMono-Bold", size: 22))
                    .foregroundColor(.black)
            }
        }
    }
}

#Preview {
    MultiplayerLobbyView(
        userId: "dummy-id",
        displayName: "Tester",
        pinCode: "123456"
    )
    .environmentObject(AuthViewModel())
    .previewDevice("iPad Pro (11-inch)")
    .previewInterfaceOrientation(.landscapeLeft)
}
