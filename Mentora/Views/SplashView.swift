//
//  SplashView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//

import SwiftUI

struct SplashView: View {
    @State private var showContent = false

    var body: some View {
        ZStack {
            Color(hex: "#FEFAED")
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 24) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeIn(duration: 1), value: showContent)

                Text("Mentora")
                    .font(.custom("IBMPlexMono-Bold", size: 28))
                    .foregroundColor(.black)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeIn(duration: 1.5), value: showContent)

                Text("Where learning and fun meets")
                    .font(.custom("IBMPlexMono-Regular", size: 17))
                    .foregroundColor(.black)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeIn(duration: 2), value: showContent)
            }
        }
        .onAppear {
            showContent = true
        }
    }
}


#Preview {
    SplashView()
}
