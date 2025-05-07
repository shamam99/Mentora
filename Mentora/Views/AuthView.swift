//
//  AuthView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//


import SwiftUI

struct AuthView: View {
    @StateObject var authVM = AuthViewModel()
    @EnvironmentObject var gameCenterManager: GameCenterManager
    @State private var showSplash = true
    @State private var authStarted = false

    var body: some View {
        NavigationStack {
            Group {
                if let _ = authVM.user {
                    HomeView()
                        .environmentObject(authVM)
                } else if let error = authVM.error {
                    VStack(spacing: 24) {
                        Spacer()
                        Text("Login Failed")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)

                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)

                        Spacer()
                    }
                    .padding()
                    .background(Color.black.ignoresSafeArea())
                } else {
                    SplashView()
                        .onAppear {
                            startLoginIfNeeded()
                        }
                }
            }
        }
    }

    private func startLoginIfNeeded() {
        guard authVM.user == nil else { return }

        print("[AuthView] Starting Game Center auth...")

        gameCenterManager.authenticateUser { success in
            DispatchQueue.main.async {
                if success {
                    print("[AuthView] Game Center auth succeeded")
                    authVM.login()
                } else {
                    print("[AuthView] Game Center auth failed")
                    authVM.error = "Game Center login failed."
                }
            }
        }
    }
}
