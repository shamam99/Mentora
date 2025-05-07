//
//  HomeView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//


import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("Welcome to Mentora!")
                    .font(.largeTitle)
                    .bold()

                Text("You are successfully logged in.")
                    .foregroundColor(.gray)

                NavigationLink(destination: RoomListView().environmentObject(authVM))  {
                    Text(" Create / View Rooms")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                NavigationLink(destination: JoinRoomView()) {
                    Text(" Join a Room")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                NavigationLink(destination: AchievementsView()) {
                    Text(" My Achievements")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
}
