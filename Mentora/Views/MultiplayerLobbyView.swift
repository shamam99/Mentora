//
//  MultiplayerLobbyView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//


import SwiftUI

struct MultiplayerLobbyView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Multiplayer Lobby")
                .font(.largeTitle)
                .bold()

            Text("Create a room and wait for others to join.")
                .foregroundColor(.gray)

            Spacer()
        }
        .padding()
        .navigationTitle("Multiplayer")
    }
}
