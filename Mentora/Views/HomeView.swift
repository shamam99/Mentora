//
//  HomeView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//


import SwiftUI
import AVKit

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var pressedButton: String? = nil
    @State private var navCreate = false
    @State private var navJoin = false
    @State private var navAchievements = false
    @State private var showDemoVideo = false


    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FEFAED").ignoresSafeArea()
                Image("bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: - Header
                    HStack {
                        Text("Welcome \(authVM.user?.displayName ?? "friend") !")
                            .font(.custom("IBMPlexMono-Bold", size: 34))
                            .foregroundColor(.black)
                            .padding(.leading, 40)
                        Spacer()

                        // Achievements Button
                        MentoraShadowButton(
                            label: "Achievements",
                            defaultColor: "#F3CC02",
                            pressedColor: "#AA8F00",
                            width: 160,
                            height: 60,
                            fontSize: 18,
                            cornerRadius: 10,
                            isPressed: pressedButton == "achievements",
                            action: {
                                pressedButton = "achievements"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    navAchievements = true
                                    pressedButton = nil
                                }
                            }
                        )
                        .padding(.trailing, 40)
                    }
                    .padding(.top, 40)

                    Spacer()

                    // MARK: - Main Action Buttons
                    HStack(spacing: 60) {
                        // Create Game Button
                        MentoraShadowButton(
                            label: "Create game",
                            defaultColor: "#C09DDF",
                            pressedColor: "#945DC5",
                            width: 320,
                            height: 170,
                            fontSize: 22,
                            cornerRadius: 12,
                            isPressed: pressedButton == "create",
                            action: {
                                pressedButton = "create"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    navCreate = true
                                    pressedButton = nil
                                }
                            }
                        )

                        // Join Game Button
                        MentoraShadowButton(
                            label: "Join game",
                            defaultColor: "#C09DDF",
                            pressedColor: "#945DC5",
                            width: 320,
                            height: 170,
                            fontSize: 22,
                            cornerRadius: 12,
                            isPressed: pressedButton == "join",
                            action: {
                                pressedButton = "join"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    navJoin = true
                                    pressedButton = nil
                                }
                            }
                        )
                    }
                    .padding(.top, 10)

                    Spacer()
                }

                // MARK: - Navigation Links
                NavigationLink("", destination: ChooseModeView().environmentObject(authVM), isActive: $navCreate).hidden()
                NavigationLink("", destination: JoinRoomCodeView().environmentObject(authVM), isActive: $navJoin).hidden()
                NavigationLink(
                    "",
                    destination: AchievementsView(isActive: $navAchievements, streak: authVM.user?.streak ?? 1)
                        .environmentObject(authVM),
                    isActive: $navAchievements
                ).hidden()


            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showDemoVideo) {
                DemoVideoView()
            }

        }
    }
    
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .previewInterfaceOrientation(.landscapeLeft)
}
