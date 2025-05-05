//
//  SplashView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Spacer()
                Image(systemName: "sparkles")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                Text("Mentora")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(.bottom, 40)
            }
        }
    }
}
