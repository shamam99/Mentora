//
//  HomeButton.swift
//  Mentora
//
//  Created by Shamam Alkafri on 15/05/2025.
//


import SwiftUI

struct MentoraShadowButton: View {
    let label: String
    let defaultColor: String
    let pressedColor: String
    let width: CGFloat
    let height: CGFloat
    let fontSize: CGFloat
    let cornerRadius: CGFloat
    let isPressed: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            SoundPlayer.shared.playSound(named: "1")
            action()
        }) {
            ZStack {
                // Black shadow rectangle
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.black)
                    .frame(width: width, height: height)
                    .offset(y: 6)

                // Main button
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(hex: isPressed ? pressedColor : defaultColor))
                    .frame(width: width - 5, height: height - 6)
                    .overlay(
                        Text(label)
                            .font(.custom("IBMPlexMono-Bold", size: fontSize))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .multilineTextAlignment(.center)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}




struct HomeBottomButton: View {
    let label: String
    let defaultColor: String
    let pressedColor: String
    let isPressed: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            SoundPlayer.shared.playSound(named: "1")
            action()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black)
                    .offset(y: 6)

                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: isPressed ? pressedColor : defaultColor))
                    .overlay(
                        Text(label)
                            .font(.custom("IBMPlexMono-Bold", size: 20))
                            .foregroundColor(.black)
                            .padding(8)
                    )
            }
            .frame(width: 320, height: 80)
        }
        .buttonStyle(.plain)
    }
}
