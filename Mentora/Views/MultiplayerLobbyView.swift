
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
                    BackExitButton(icon: "chevron.left", topPadding: 40, leftPadding: 62, sound: "3") {
                        vm.leaveLobby()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                Spacer()
                
                // Player Grid (Puzzle Layout)
                PuzzleGridView(players: vm.players)
                
                Spacer()
                
                // Bottom Row: Room Code + Start Button
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
                    .padding(.bottom, 32)
                }
                .frame(height: 80)


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
    private let playerImages = ["slot1", "slot2", "slot3", "slot4"]

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let pieceSize: CGFloat = min(screenWidth * 0.32, 380)
            let charWidth: CGFloat = pieceSize * 0.7
            let charHeight: CGFloat = pieceSize * 0.95


            VStack(spacing: -pieceSize * 0.35) {
                HStack(spacing: -pieceSize * 0.1) {
                    playerSlot(index: 0, pieceSize: pieceSize, charSize: CGSize(width: charWidth, height: charHeight))
                    playerSlot(index: 1, pieceSize: pieceSize, charSize: CGSize(width: charWidth, height: charHeight))
                }

                HStack(spacing: -pieceSize * 0.11) {
                    playerSlot(index: 2, pieceSize: pieceSize, charSize: CGSize(width: charWidth, height: charHeight))
                    playerSlot(index: 3, pieceSize: pieceSize, charSize: CGSize(width: charWidth, height: charHeight))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 650)
    }

    func playerSlot(index: Int, pieceSize: CGFloat, charSize: CGSize) -> some View {
        let playerJoined = index < players.count
        let pieceImage = playerImages[index]
        let characterImage = ""

        let offsets: (top: CGFloat, leading: CGFloat) = {
            switch index {
            case 0: return (-pieceSize * 0.3, pieceSize * 0.02)
            case 1: return (-pieceSize * 0.2, pieceSize * 0.08)
            case 2: return (pieceSize * 0.04, pieceSize * 0.15)
            case 3: return (pieceSize * 0.08, pieceSize * 0.22)
            default: return (0, 0)
            }
        }()

        return ZStack {
            Image(pieceImage)
                .resizable()
                .frame(width: pieceSize, height: pieceSize)
                .opacity(playerJoined ? 1.0 : 0.3)

            if playerJoined {
                Image(characterImage)
                    .resizable()
                    .frame(width: charSize.width, height: charSize.height)
                    .padding(.top, offsets.top)
                    .padding(.leading, offsets.leading)
            }
        }
    }
}


#Preview {
    ZStack {
        Color(hex: "#FEFAED").ignoresSafeArea()
        Image("bg").resizable().scaledToFill().ignoresSafeArea()
        
        VStack {
            Spacer()
            PuzzleGridView(players: ["Player1", "Player2", "Player3", "Player4"])
            Spacer()
        }
    }
    .previewDevice("iPad Pro (13-inch)")
    .previewInterfaceOrientation(.landscapeLeft)
}
