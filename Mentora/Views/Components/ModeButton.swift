//
//  ModeButton.swift
//  Mentora
//
//  Created by Shamam Alkafri on 15/05/2025.
//


import SwiftUI

struct ModeButton: View {
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
                    .offset(y: 8)

                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: isPressed ? pressedColor : defaultColor))
                    .overlay(
                        Text(label)
                            .font(.custom("IBMPlexMono-Bold", size: 22))
                            .foregroundColor(.black)
                            .padding(12)
                            .multilineTextAlignment(.center)
                    )
            }
            .frame(width: 310, height: 160)
        }
        .buttonStyle(.plain)
    }
}
