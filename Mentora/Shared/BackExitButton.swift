//
//  BackExitButton.swift
//  Mentora
//
//  Created by Shamam Alkafri on 24/05/2025.
//

import SwiftUI

struct BackExitButton: View {
    let icon: String
    let topPadding: CGFloat
    let leftPadding: CGFloat
    let sound: String
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: {
                SoundPlayer.shared.playSound(named: sound)
                action()
            }) {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.black)
                    .padding()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, topPadding)
        .padding(.leading, leftPadding)
    }
}
