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

            HStack(alignment: .top, spacing: 10) {

                // MARK: - Left Sidebar
                VStack(spacing: 10) {
                    Button(action: {
                        SoundPlayer.shared.playSound(named: "3")
                        isActive = false
                    }) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                            .padding(.top, 20)
                    }
                    .padding(.bottom, 70)
                    .padding(.leading, -60)

                    VStack(spacing: -40) {
                        Image("profileStar")
                            .resizable()
                            .frame(width: 90, height: 90)

                        Text("\(vm.currentStreak) / 6")
                            .font(.custom("IBMPlexMono-Regular", size: 22))
                            .foregroundColor(.black)
                            .padding(.top, 58)

                        Image("profileImage")
                            .resizable()
                            .frame(width: 240, height: 260)

                        Spacer()
                    }
                }
                .padding(.leading, 30)

                // MARK: - Right Content
                VStack(alignment: .leading, spacing: 42) {

                    // 🟦 Streaks
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Streaks")
                            .font(.custom("IBMPlexMono-Bold", size: 28))
                            .foregroundColor(.black)

                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#0DA8E2"))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.black, lineWidth: 5))

                            HStack(spacing: 104) {
                                ForEach(1...6, id: \.self) { day in
                                    VStack(spacing: 6) {
                                        Text("\(day)")
                                            .font(.custom("IBMPlexMono-Bold", size: 28))
                                            .frame(width: 70, height: 80)
                                            .background(vm.currentStreak >= day ? .black : .clear)
                                            .foregroundColor(vm.currentStreak >= day ? .white : .black)
                                            .cornerRadius(10)

                                        Text("Day \(day)")
                                            .font(.custom("IBMPlexMono-Regular", size: 16))
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                            .padding()
                        }
                        .frame(height: 160)
                    }

                    // 🟦 Badges
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Badges")
                            .font(.custom("IBMPlexMono-Bold", size: 28))
                            .foregroundColor(.black)

                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#0DA8E2"))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.black, lineWidth: 5))

                            HStack(alignment: .top, spacing: 90) {
                                ForEach(vm.achievements) { badge in
                                    VStack(spacing: 8) {
                                        Image(badge.iconName)
                                            .resizable()
                                            .frame(width: 70, height: 70)

                                        Text(badge.title)
                                            .font(.custom("IBMPlexMono-Bold", size: 18))
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.black)

                                        Text(badge.description)
                                            .font(.custom("IBMPlexMono-Medium", size: 16))
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: 160)
                                }
                            }
                            .padding(.vertical)
                        }
                        .frame(height: 260)
                    }

                    // 🟦 Saved Questions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Leader Board")
                            .font(.custom("IBMPlexMono-Bold", size: 28))
                            .foregroundColor(.black)

                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#0DA8E2"))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.black, lineWidth: 5))
                        }
                        .frame(height: 180)
                    }

                    Spacer()
                }
                .padding(.top, 80)
                .padding(.leading, -30)
                .padding(.horizontal, 50)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    @State var isActive = true
    return AchievementsView(isActive: $isActive, streak: 1) // Example preview streak
        .environmentObject(AuthViewModel())
}
