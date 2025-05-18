//
//  HomeView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//


import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var pressedButton: String? = nil
    @State private var navCreate = false
    @State private var navJoin = false
    @State private var navAchievements = false

    var body: some View {
        NavigationStack {
            Spacer()
            ZStack {
                Color(hex: "#FEFAED").ignoresSafeArea()
                Image("bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 40) {
                    Text("Welcome friend !")
                        .font(.custom("IBMPlexMono-Bold", size: 34))
                        .foregroundColor(.black)
                        .padding(.leading, 40)
                        .padding(.top, 40)
                    
                    Spacer()

                    HStack(spacing: 65) {
                        HomeButton(
                            label: "Achievements",
                            defaultColor: "#F3CC02",
                            pressedColor: "#AA8F00",
                            isPressed: pressedButton == "achievements",
                            action: {
                                pressedButton = "achievements"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    navAchievements = true
                                    pressedButton = nil
                                }
                            })

                        HomeButton(
                            label: "Create game",
                            defaultColor: "#C09DDF",
                            pressedColor: "#945DC5",
                            isPressed: pressedButton == "create",
                            action: {
                                pressedButton = "create"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    navCreate = true
                                    pressedButton = nil
                                }
                            })

                        HomeButton(
                            label: "Join game",
                            defaultColor: "#0DA8E2",
                            pressedColor: "#007CAA",
                            isPressed: pressedButton == "join",
                            action: {
                                pressedButton = "join"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    navJoin = true
                                    pressedButton = nil
                                }
                            })
                    }
                    .padding(.horizontal, 40)

                    HStack {
                        Spacer()
                        HomeBottomButton(
                            label: "Check it out first !",
                            defaultColor: "#05D96A",
                            pressedColor: "#009C4A",
                            isPressed: pressedButton == "check",
                            action: {
                                pressedButton = "check"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    pressedButton = nil
                                    // stub
                                }
                            })
                        Spacer()
                    }
                    .padding(.top, 20)

                    Spacer()
                }

                // MARK: - Navigation Links
                NavigationLink("", destination: ChooseModeView().environmentObject(authVM), isActive: $navCreate).hidden()
                NavigationLink("", destination: JoinRoomCodeView().environmentObject(authVM), isActive: $navJoin).hidden()
                NavigationLink("", destination: AchievementsView().environmentObject(authVM), isActive: $navAchievements).hidden()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .previewDevice("iPad Pro (11-inch)")
        .previewInterfaceOrientation(.landscapeLeft)
}
