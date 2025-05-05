//
//  HomeView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text(" Welcome to Mentora!")
                .font(.largeTitle)
                .bold()
            Text("You are successfully logged in.")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
