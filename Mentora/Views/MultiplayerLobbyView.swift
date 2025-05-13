
//  MultiplayerLobbyView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//

import SwiftUI

struct MultiplayerLobbyView: View {
    @StateObject private var vm = MultiplayerLobbyViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    @State private var navigateToGame = false

    let userId: String
    let displayName: String
    let pinCode: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Room PIN: \(vm.pinCode)")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                Text("Players").font(.headline)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(vm.players, id: \.self) { name in
                            Text(name)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }

                if vm.isHost {
                    Button("Start Game") {
                        vm.startGame()
                    }
                    .disabled(!vm.canStartGame)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(vm.canStartGame ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                NavigationLink(
                    destination: MultiplayerGameViewWrapper(gameVM: vm.gameVM),
                    isActive: $vm.navigateToGame,
                    label: { EmptyView() }
                )
                .hidden()
            }
            .navigationTitle("Multiplayer Lobby")
            .onAppear {
                vm.joinRoom(userId: userId, displayName: displayName, pinCode: pinCode)
            }
        }
    }
}
