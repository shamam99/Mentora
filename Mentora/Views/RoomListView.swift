//
//  RoomListView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//


import SwiftUI

struct RoomListView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Choose Game Mode")
                .font(.title)
                .bold()
                .padding(.top, 40)

            NavigationLink("Start Solo Game") {
                SoloGameView(vm: SoloGameViewModel(userId: authVM.user?._id ?? ""))
                Text(" Start Solo Game")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            NavigationLink(destination: MultiplayerLobbyView()) {
                Text(" Create Multiplayer Room")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Rooms")
    }
}
