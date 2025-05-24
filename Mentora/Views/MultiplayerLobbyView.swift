
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
                        SoundPlayer.shared.playSound(named: "3")
                        vm.leaveLobby()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 62)
                    Spacer()
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Player Grid (Puzzle Layout)
                PuzzleGridView(players: vm.players)
                
                Spacer()
                
                // Bottom Row: Room Code + Start Button
                HStack {
                    // Room Code
                    Text("Code : \(vm.pinCode)")
                        .font(.custom("IBMPlexMono-Bold", size: 28))
                        .foregroundColor(.black)
                        .padding(.leading, 70)
                    
                    Spacer()
                    
                    // Host Start Button
                    if vm.isHost {
                        Button(action: {
                            SoundPlayer.shared.playSound(named: "1")
                            vm.startGame()
                        }) {
                            Text("Start room")
                                .font(.custom("IBMPlexMono-Bold", size: 19))
                                .foregroundColor(.black)
                                .frame(width: 170, height: 58)
                                .background(vm.canStartGame ? Color(hex: "#05D96A") : Color.gray)
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.25), radius: 2, x: 2, y: 2)
                        }
                        .padding(.trailing, 40)
                        .disabled(!vm.canStartGame)
                    }
                }
                .padding(.bottom, 26)
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
        VStack(spacing: -215) {
            HStack(spacing: -85) {
                playerSlot(index: 0)
                playerSlot(index: 1)
            }

            HStack(spacing: -95) {
                playerSlot(index: 2)
                playerSlot(index: 3)
            }
        }
    }

    // MARK: - Unified Slot with Per-Card Customization
    func playerSlot(index: Int) -> some View {
        let playerJoined = index < players.count
        let pieceImage = playerImages[index]
        let characterImage = "character\(index + 1)"

        // Custom sizes per index
        let characterOffset: (top: CGFloat, leading: CGFloat) = {
            switch index {
            case 0: return (-145, 10)
            case 1: return (-85, 40)
            case 2: return (20, 90)
            case 3: return (35, 115)
            default: return (0, 0)
            }
        }()

        return ZStack {
            Image(pieceImage)
                .resizable()
                .frame(width: 480, height: 480)
                .opacity(playerJoined ? 1.0 : 0.3)

            if playerJoined {
                VStack(spacing: 10) {
                    Image(characterImage)
                        .resizable()
                        .frame(width: 390, height: 460)
                        .padding(.top, characterOffset.top)
                        .padding(.leading, characterOffset.leading)


                }
            }
        }
    }



    // MARK: - Bottom Row Layout
    func bottomPlayerSlot(index: Int) -> some View {
        let playerJoined = index < players.count
        let pieceImage = playerImages[index]
        let characterImage = "character\(index + 1)"

        return ZStack {
            Image(pieceImage)
                .resizable()
                .frame(width: 480, height: 480)
                .opacity(playerJoined ? 1.0 : 0.3)

            if playerJoined {
                VStack(spacing: 10) {
                    Image(characterImage)
                        .resizable()
                        .frame(width: 370, height: 220)
                        .padding(.top, 45)
                        .padding(.leading,80)

                }
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
