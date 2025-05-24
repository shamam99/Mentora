//
//  MultiplayerResultsView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 18/05/2025.
//


import SwiftUI

struct MultiplayerResultsView: View {
    let players: [PlayerResult]
    let vm: MultiplayerGameViewModel
    @Binding var isInMultiplayerGame: Bool

    var body: some View {
        ZStack {
            Color(hex: "#FEFAED").ignoresSafeArea()
            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                GeometryReader { geometry in
                    let screenWidth = geometry.size.width
                    let totalContentWidth: CGFloat = CGFloat(players.count) * 250 + CGFloat(players.count - 1) * 20
                    let horizontalPadding = max((screenWidth - totalContentWidth) / 2, 20)
                    
                    VStack {
                        HStack {
                            BackExitButton(icon: "xmark", topPadding: 30, leftPadding: 60, sound: "3") {
                                vm.leaveGame()
                                SocketService.shared.disconnect()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    NavigationUtil.popToRootView()
                                }
                            }
                            Spacer()
                        }
                        
                        Text("We Have A Winner!")
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .kerning(2)
                            .foregroundColor(.black)
                            .padding(.top, 1)
                            .padding(.bottom, 80)
                        
                        Spacer()
                        
                        HStack(alignment: .bottom, spacing: 20) {
                            ForEach(players.indices, id: \.self) { index in
                                let player = players[index]
                                let isWinner = index == 0
                                let height = isWinner ? 520 : index == 2 ? 470 : index == 1 ? 340 : 240
                                
                                VStack(spacing: 10) {
                                    ZStack(alignment: .bottom) {
                                        if isWinner {
                                            Image("WinnerStar")
                                                .resizable()
                                                .frame(width: 90, height: 90)
                                                .offset(y: -CGFloat(height) - 50)
                                                .zIndex(1)
                                        }
                                        
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: player.podiumColorHex))
                                            .frame(width: 250, height: CGFloat(height))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 1)
                                                    .stroke(Color.black, lineWidth: 5)
                                            )
                                        
                                        Image(player.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 188, height: 270)
                                            .offset(y: -CGFloat(height / 2) + 80)
                                    }
                                    
                                    Text(player.displayName)
                                        .font(.system(size: 25, weight: .bold, design: .monospaced))
                                        .foregroundColor(.black)
                                        .kerning(1.5)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 10)
                        
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    @State var dummyIsInGame = true

    return MultiplayerResultsView(
        players: [
            PlayerResult(userId: "1", displayName: "Winner", score: 120, imageName: "PlayerOrange", podiumColorHex: "#F67348"),
            PlayerResult(userId: "2", displayName: "player2", score: 80, imageName: "PlayerPurple", podiumColorHex: "#C09DDF"),
            PlayerResult(userId: "3", displayName: "player3", score: 60, imageName: "PlayerPink", podiumColorHex: "#F9A7F9"),
            PlayerResult(userId: "3", displayName: "player4", score: 40, imageName: "PlayerYellow", podiumColorHex: "#F3CC02")
        ],
        vm: MultiplayerGameViewModel.previewDummy(),
        isInMultiplayerGame: .constant(true) 
    )
    .previewInterfaceOrientation(.landscapeLeft)
}
