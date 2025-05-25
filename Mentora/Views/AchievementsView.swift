//
//  AchievementsView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//


import SwiftUI

struct AchievementsView: View {
    @Binding var isActive: Bool
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm: AchievementsViewModel

    init(isActive: Binding<Bool>, streak: Int) {
        self._isActive = isActive
        self._vm = StateObject(wrappedValue: AchievementsViewModel(streak: streak))
    }

    var body: some View {
        ZStack {
            Color(hex: "#FEFAED").ignoresSafeArea()
            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            HStack(alignment: .top, spacing: 30) {
                // MARK: - Sidebar
                VStack(spacing: 66) {
                    BackExitButton(icon: "chevron.left", topPadding: 20, leftPadding: 0, sound: "3") {
                        isActive = false
                    }


                    VStack(spacing: 0) {
                        Image("profileStar")
                            .resizable()
                            .frame(width: 100, height: 100)

                        Text("\(vm.currentStreak) / 6")
                            .font(.custom("IBMPlexMono-Regular", size: 24))
                            .foregroundColor(.black)
                            .padding(.top, 10)
                            .padding(.bottom, -30)

                        Image("profileImage")
                            .resizable()
                            .frame(width: 220, height: 240)

                        Spacer()
                    }
                }
                .padding(.leading, 24)
                .frame(width: 280)

                // MARK: - Main Content
                VStack(alignment: .leading, spacing: 50) {
                    Spacer()

                    // === Streaks Section ===
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Streaks")
                            .font(.custom("IBMPlexMono-Bold", size: 32))
                            .foregroundColor(.black)

                        GeometryReader { geo in
                            let boxSize = geo.size.width / 9
                            let spacing = geo.size.width / 20

                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "#0DA8E2"))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.black, lineWidth: 4))

                                HStack(spacing: spacing) {
                                    ForEach(1...6, id: \.self) { day in
                                        VStack(spacing: 6) {
                                            Text("\(day)")
                                                .font(.custom("IBMPlexMono-Bold", size: boxSize * 0.5))
                                                .frame(width: boxSize, height: boxSize)
                                                .background(vm.currentStreak >= day ? Color.black : .clear)
                                                .foregroundColor(vm.currentStreak >= day ? .white : .black)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(.black, lineWidth: 2)
                                                )
                                                .cornerRadius(8)

                                            Text("Day \(day)")
                                                .font(.custom("IBMPlexMono-Regular", size: 14))
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                            }
                        }
                        .frame(height: 180)
                    }

                    // === Badges Section ===
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Badges")
                            .font(.custom("IBMPlexMono-Bold", size: 32))
                            .foregroundColor(.black)

                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#0DA8E2"))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.black, lineWidth: 4))

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 40) {
                                    ForEach(vm.achievements) { badge in
                                        VStack(spacing: 10) {
                                            Image(badge.iconName)
                                                .resizable()
                                                .frame(width: 70, height: 70)

                                            Text(badge.title)
                                                .font(.custom("IBMPlexMono-Bold", size: 22))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.black)

                                            Text(badge.description)
                                                .font(.custom("IBMPlexMono-Regular", size: 18))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.black)
                                                .frame(width: 120)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 32)
                            }
                        }
                        .frame(height: 280)
                    }

                    Spacer()
                }
                .padding(.top, 60)
                .padding(.trailing, 50)
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    @State var isActive = true
    return AchievementsView(isActive: $isActive, streak: 4)
        .environmentObject(AuthViewModel())
        .previewDevice("iPad Pro (11-inch)")
        .previewInterfaceOrientation(.landscapeLeft)
}
