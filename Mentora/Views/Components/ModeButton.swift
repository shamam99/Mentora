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
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black)
                .frame(width: 324, height: 306)

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
            .offset(y: -10)
            .buttonStyle(.plain)
        }
    }
}
