//
//  HomeButton.swift
//  Mentora
//
//  Created by Shamam Alkafri on 15/05/2025.
//


import SwiftUI

struct HomeButton: View {
    let label: String
    let defaultColor: String
    let pressedColor: String
    let isPressed: Bool
    let action: () -> Void

    var body: some View {
        ZStack {
            // Bottom black layer (fake shadow)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black)
                .frame(width: 324, height: 306) // slightly taller

            // Actual button layer — slightly offset up
            Button(action: action) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: isPressed ? pressedColor : defaultColor))
                    .frame(width: 317, height: 276)
                    .overlay(
                        Text(label)
                            .font(.custom("IBMPlexMono-Bold", size: 28))
                            .foregroundColor(.black)
                    )
            }
            .offset(y: -10) // lift up to reveal bottom frame
            .buttonStyle(.plain)
        }
    }
}






struct HomeBottomButton: View {
    let label: String
    let defaultColor: String
    let pressedColor: String
    let isPressed: Bool
    let action: () -> Void

    var body: some View {
        ZStack {
            // Static black bottom layer
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black)
                .frame(width: 493, height: 122)

            // Active button on top — slightly moved up
            Button(action: action) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: isPressed ? pressedColor : defaultColor))
                    .frame(width: 483, height: 96)
                    .overlay(
                        Text(label)
                            .font(.custom("IBMPlexMono-SemiBold", size: 28))
                            .foregroundColor(.black)
                    )
            }
            .offset(y: -10)
            .buttonStyle(.plain)
        }
    }
}
